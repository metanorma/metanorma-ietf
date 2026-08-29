# Bug Report: Circular Autoload Dependency in Register Setup

**Severity:** High — prevents any non-ISO flavor from loading via `require "metanorma/document"`

**Affected file:** `lib/metanorma/registers/setup.rb` lines 14–15

## Description

`registers/setup.rb` defines module-level constants that trigger autoloads before the `Setup` module's methods are fully defined:

```ruby
module Metanorma
  module Registers
    module Setup
      SD = Metanorma::StandardDocument   # line 14 — triggers autoload of standard_document
      ISO = Metanorma::IsoDocument       # line 15 — triggers autoload of iso_document

      class << self
        def setup_iso_register            # line 21 — not yet defined when line 15 autoloads iso_document.rb
          ...
        end
      end
    end
  end
end
```

## How it breaks

1. `ietf_document.rb` line 11 calls `Metanorma::Registers::Setup.setup_ietf_register`
2. This triggers autoload of `registers/setup.rb`
3. Line 15: `ISO = Metanorma::IsoDocument` triggers autoload of `iso_document.rb`
4. `iso_document.rb` line 16: `Metanorma::Registers::Setup.setup_iso_register`
5. But `setup_iso_register` isn't defined yet — the `class << self` block hasn't been evaluated (still at line 15)
6. **`NoMethodError: undefined method 'setup_iso_register'`**

## Symmetric problem

Every `*_document.rb` file calls `Registers::Setup.setup_*_register` at load time. Any two flavors that are both referenced inside `setup.rb` will have this circular dependency. For example, if a new flavor's register setup references `Metanorma::IeeeDocument`, loading `ieee_document.rb` would trigger `setup.rb` which references `IsoDocument`, which calls `setup_iso_register` before it's defined.

## Current workaround

metanorma-ietf forces the loading order in its transformer.rb:

```ruby
require "metanorma/document"

# Force-load order to break the circular autoload
Metanorma::StandardDocument::Sections
Metanorma::IsoDocument::Sections
```

This pre-resolves `Metanorma::IsoDocument` before `ietf_document.rb` references `Registers::Setup`, so when `setup.rb` loads, `ISO = Metanorma::IsoDocument` resolves without triggering a new autoload.

## Suggested fix

Move the module-level constants inside the methods that use them, or lazy-initialize them:

```ruby
module Metanorma
  module Registers
    module Setup
      class << self
        def setup_iso_register
          sd = Metanorma::StandardDocument
          iso = Metanorma::IsoDocument
          reg = Lutaml::Model::Register.new(:iso_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::ClauseSection,
            to_type:   iso::Sections::IsoClauseSection,
          )
          # ... etc
        end

        def setup_ietf_register
          sd = Metanorma::StandardDocument
          ietf = Metanorma::IetfDocument
          reg = Lutaml::Model::Register.new(:ietf_document)
          Lutaml::Model::GlobalRegister.register(reg)
          # ... etc
        end
      end
    end
  end
end
```

This way, no autoloads are triggered at module-definition time, and the circular dependency is eliminated.

## Secondary issue: IETF content model gaps

While adapting the IETF transformer to the restructured metanorma-document, we found these model gaps. These are **not blockers** (we have workarounds), but they represent model design questions for the metanorma-document team:

### 1. `IetfContentSection` lacks `unnumbered` and `toc`

`IetfClauseSection` (extends `ClauseSection`) inherits `unnumbered` and `toc` from its base class. But `IetfContentSection` (extends `ContentSection`) does not have these attributes. In the IETF context, preface content sections can be unnumbered, so the forward transformer needs to check `unnumbered` on content sections too.

**Current workaround:** `rescue NoMethodError` guards in the forward transformer.

### 2. No IETF-specific term types

The `StandardDocument` base provides `Term`, `TermsSection`, `TermDefinition`, `TermExpression`, `TermNameElement`, and `Designation`. But IETF documents that include terminology need these same types. The reverse transformer uses `StandardDocument` base types instead of `IsoDocument` types (which is correct per the architecture), but there's no IETF-specific customization layer.

**Status:** Working with `StandardDocument` base types. No IETF-specific term model needed yet, but the metanorma-document team should be aware that IETF may need term model extensions in the future.

### 3. `Preface.content` type is `ContentSection`

The `Preface` model's `content` attribute is typed as `ContentSection`, which maps `"clause" → :subsection`. But some flavors (like IETF) put clause-like content in preface `content`. The register substitution `ContentSection → IetfContentSection` applies to all content items, including objects that behave more like `ClauseSection`. This causes attribute mismatch during serialization.

**Current workaround:** The reverse transformer creates `IetfContentSection` instances for preface content, which serializes correctly. But if richer clause features (amend, terms, definitions) are needed in preface content, the type system needs a more flexible approach.
