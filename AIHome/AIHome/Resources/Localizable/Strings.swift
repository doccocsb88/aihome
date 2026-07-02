// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum AdvancedTools {
    /// New Wall
    internal static var newWall: String { L10n.tr("Localizable", "advanced_tools.new_wall", fallback: "New Wall") }
    /// Reference
    internal static var reference: String { L10n.tr("Localizable", "advanced_tools.reference", fallback: "Reference") }
    /// Remove
    internal static var remove: String { L10n.tr("Localizable", "advanced_tools.remove", fallback: "Remove") }
    /// Replace
    internal static var replace: String { L10n.tr("Localizable", "advanced_tools.replace", fallback: "Replace") }
    /// Advanced Tools
    internal static var title: String { L10n.tr("Localizable", "advanced_tools.title", fallback: "Advanced Tools") }
  }
  internal enum Common {
    /// Cancel
    internal static var cancel: String { L10n.tr("Localizable", "common.cancel", fallback: "Cancel") }
    /// Close
    internal static var close: String { L10n.tr("Localizable", "common.close", fallback: "Close") }
    /// Delete
    internal static var delete: String { L10n.tr("Localizable", "common.delete", fallback: "Delete") }
    /// OK
    internal static var ok: String { L10n.tr("Localizable", "common.ok", fallback: "OK") }
  }
  internal enum ExteriorFlow {
    /// Tailor the prompt with your own instructions...
    internal static var promptPlaceholder: String { L10n.tr("Localizable", "exterior_flow.prompt_placeholder", fallback: "Tailor the prompt with your own instructions...") }
    /// Exterior Redesign
    internal static var title: String { L10n.tr("Localizable", "exterior_flow.title", fallback: "Exterior Redesign") }
  }
  internal enum Flow {
    /// CONTINUE
    internal static var `continue`: String { L10n.tr("Localizable", "flow.continue", fallback: "CONTINUE") }
    /// GENERATE
    internal static var generate: String { L10n.tr("Localizable", "flow.generate", fallback: "GENERATE") }
    /// GET STARTED
    internal static var getStarted: String { L10n.tr("Localizable", "flow.get_started", fallback: "GET STARTED") }
    /// Step %d/%d
    internal static func step(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "flow.step", p1, p2, fallback: "Step %d/%d")
    }
  }
  internal enum GenerationLoading {
    /// Generating...
    internal static var generating: String { L10n.tr("Localizable", "generation_loading.generating", fallback: "Generating...") }
    internal enum Failure {
      /// BACK TO DESIGN
      internal static var backToDesign: String { L10n.tr("Localizable", "generation_loading.failure.back_to_design", fallback: "BACK TO DESIGN") }
      /// Choose a clear exterior photo showing the front, side, or back of the house, then try again.
      internal static var exteriorPhotoMessage: String { L10n.tr("Localizable", "generation_loading.failure.exterior_photo_message", fallback: "Choose a clear exterior photo showing the front, side, or back of the house, then try again.") }
      /// We couldn't process your redesign request this time. Please check your photo or instructions and try again.
      internal static var message: String { L10n.tr("Localizable", "generation_loading.failure.message", fallback: "We couldn't process your redesign request this time. Please check your photo or instructions and try again.") }
      /// Generation Failed
      internal static var title: String { L10n.tr("Localizable", "generation_loading.failure.title", fallback: "Generation Failed") }
      /// TRY AGAIN
      internal static var tryAgain: String { L10n.tr("Localizable", "generation_loading.failure.try_again", fallback: "TRY AGAIN") }
    }
  }
  internal enum History {
    /// Delete (%d)
    internal static func deleteSelected(_ p1: Int) -> String {
      return L10n.tr("Localizable", "history.delete_selected", p1, fallback: "Delete (%d)")
    }
    /// History
    internal static var title: String { L10n.tr("Localizable", "history.title", fallback: "History") }
    internal enum DeleteConfirmation {
      /// This action cannot be undone.
      internal static var message: String { L10n.tr("Localizable", "history.delete_confirmation.message", fallback: "This action cannot be undone.") }
      /// Delete selected projects?
      internal static var title: String { L10n.tr("Localizable", "history.delete_confirmation.title", fallback: "Delete selected projects?") }
    }
    internal enum Empty {
      /// Create New Project
      internal static var createProject: String { L10n.tr("Localizable", "history.empty.create_project", fallback: "Create New Project") }
      /// Create a new space and watch your
      /// ideas come to life.
      internal static var message: String { L10n.tr("Localizable", "history.empty.message", fallback: "Create a new space and watch your\nideas come to life.") }
      /// Start your first project
      internal static var title: String { L10n.tr("Localizable", "history.empty.title", fallback: "Start your first project") }
    }
    internal enum FilterEmpty {
      /// Try adjusting or resetting your filters.
      internal static var message: String { L10n.tr("Localizable", "history.filter_empty.message", fallback: "Try adjusting or resetting your filters.") }
      /// Reset Filters
      internal static var resetFilters: String { L10n.tr("Localizable", "history.filter_empty.reset_filters", fallback: "Reset Filters") }
      /// No matching projects
      internal static var title: String { L10n.tr("Localizable", "history.filter_empty.title", fallback: "No matching projects") }
    }
  }
  internal enum Home {
    /// ADVANCED EDITING
    internal static var advancedEditing: String { L10n.tr("Localizable", "home.advanced_editing", fallback: "ADVANCED EDITING") }
    /// Home
    internal static var title: String { L10n.tr("Localizable", "home.title", fallback: "Home") }
    internal enum Tool {
      internal enum Exterior {
        /// Stunning facade and garden renders.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.exterior.subtitle", fallback: "Stunning facade and garden renders.") }
        /// Exterior AI
        internal static var title: String { L10n.tr("Localizable", "home.tool.exterior.title", fallback: "Exterior AI") }
      }
      internal enum Garden {
        /// Transform outdoor spaces instantly.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.garden.subtitle", fallback: "Transform outdoor spaces instantly.") }
        /// Garden Redesign
        internal static var title: String { L10n.tr("Localizable", "home.tool.garden.title", fallback: "Garden Redesign") }
      }
      internal enum Interior {
        /// Instant room styling transformations.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.interior.subtitle", fallback: "Instant room styling transformations.") }
        /// Interior AI
        internal static var title: String { L10n.tr("Localizable", "home.tool.interior.title", fallback: "Interior AI") }
      }
      internal enum NewFlooring {
        /// Transform your floors instantly.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.new_flooring.subtitle", fallback: "Transform your floors instantly.") }
        /// New Flooring
        internal static var title: String { L10n.tr("Localizable", "home.tool.new_flooring.title", fallback: "New Flooring") }
      }
      internal enum NewWalls {
        /// Refresh walls with new color & textures.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.new_walls.subtitle", fallback: "Refresh walls with new color & textures.") }
        /// New Walls
        internal static var title: String { L10n.tr("Localizable", "home.tool.new_walls.title", fallback: "New Walls") }
      }
      internal enum ReferenceStyle {
        /// Replicate any design look instantly.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.reference_style.subtitle", fallback: "Replicate any design look instantly.") }
        /// Reference Style
        internal static var title: String { L10n.tr("Localizable", "home.tool.reference_style.title", fallback: "Reference Style") }
      }
      internal enum RemoveObjects {
        /// Instantly erase clutter and items.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.remove_objects.subtitle", fallback: "Instantly erase clutter and items.") }
        /// Remove Objects
        internal static var title: String { L10n.tr("Localizable", "home.tool.remove_objects.title", fallback: "Remove Objects") }
      }
      internal enum ReplaceObjects {
        /// Swap furniture and decor easily.
        internal static var subtitle: String { L10n.tr("Localizable", "home.tool.replace_objects.subtitle", fallback: "Swap furniture and decor easily.") }
        /// Replace Objects
        internal static var title: String { L10n.tr("Localizable", "home.tool.replace_objects.title", fallback: "Replace Objects") }
      }
    }
  }
  internal enum Inspiration {
    /// Like inspiration
    internal static var like: String { L10n.tr("Localizable", "inspiration.like", fallback: "Like inspiration") }
    /// Inspiration
    internal static var title: String { L10n.tr("Localizable", "inspiration.title", fallback: "Inspiration") }
    /// Unlike inspiration
    internal static var unlike: String { L10n.tr("Localizable", "inspiration.unlike", fallback: "Unlike inspiration") }
    internal enum Category {
      /// Exterior
      internal static var exterior: String { L10n.tr("Localizable", "inspiration.category.exterior", fallback: "Exterior") }
      /// Garden
      internal static var garden: String { L10n.tr("Localizable", "inspiration.category.garden", fallback: "Garden") }
      /// Interior
      internal static var interior: String { L10n.tr("Localizable", "inspiration.category.interior", fallback: "Interior") }
    }
    internal enum Detail {
      /// Back
      internal static var back: String { L10n.tr("Localizable", "inspiration.detail.back", fallback: "Back") }
      /// OR
      internal static var or: String { L10n.tr("Localizable", "inspiration.detail.or", fallback: "OR") }
      /// REDESIGN
      internal static var redesign: String { L10n.tr("Localizable", "inspiration.detail.redesign", fallback: "REDESIGN") }
      /// Show after image
      internal static var showAfterImage: String { L10n.tr("Localizable", "inspiration.detail.show_after_image", fallback: "Show after image") }
      /// Show before image
      internal static var showBeforeImage: String { L10n.tr("Localizable", "inspiration.detail.show_before_image", fallback: "Show before image") }
    }
    internal enum Item {
      internal enum Exterior27 {
        /// A serene outdoor escape featuring natural timber and grounded, organic hues.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-27.subtitle", fallback: "A serene outdoor escape featuring natural timber and grounded, organic hues.") }
        /// balcony modern farm house earthy tones
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-27.title", fallback: "balcony modern farm house earthy tones") }
      }
      internal enum Exterior28 {
        /// Timeless architectural details tucked away in a lush, ancient forest.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-28.subtitle", fallback: "Timeless architectural details tucked away in a lush, ancient forest.") }
        /// apartment century woodland retreat
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-28.title", fallback: "apartment century woodland retreat") }
      }
      internal enum Exterior29 {
        /// Sharp, contemporary edges finished in warm, desert-inspired tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-29.subtitle", fallback: "Sharp, contemporary edges finished in warm, desert-inspired tones.") }
        /// house modern neutral sands
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-29.title", fallback: "house modern neutral sands") }
      }
      internal enum Exterior30 {
        /// A breezy, sprawling layout bathed in warm, sunset-inspired tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-30.subtitle", fallback: "A breezy, sprawling layout bathed in warm, sunset-inspired tones.") }
        /// ranch alfresco kitchen peach meadow
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-30.title", fallback: "ranch alfresco kitchen peach meadow") }
      }
      internal enum Exterior31 {
        /// Warm Mediterranean textures overlooking wide, sun-soaked fields.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-31.subtitle", fallback: "Warm Mediterranean textures overlooking wide, sun-soaked fields.") }
        /// ranch mediterranean sunny pastures
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-31.title", fallback: "ranch mediterranean sunny pastures") }
      }
      internal enum Exterior32 {
        /// Lush tropical forms grounded by sophisticated, cool grey finishes.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-32.subtitle", fallback: "Lush tropical forms grounded by sophisticated, cool grey finishes.") }
        /// residential tropical modern slate shades
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-32.title", fallback: "residential tropical modern slate shades") }
      }
      internal enum Exterior33 {
        /// Refined bohemian textures layered with calm, sophisticated blues.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-33.subtitle", fallback: "Refined bohemian textures layered with calm, sophisticated blues.") }
        /// retail boho refined blues
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-33.title", fallback: "retail boho refined blues") }
      }
      internal enum Exterior34 {
        /// Ultra-modern coastal luxury designed to breathe with the ocean air.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.exterior-34.subtitle", fallback: "Ultra-modern coastal luxury designed to breathe with the ocean air.") }
        /// villa contemporary ocean breeze
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.exterior-34.title", fallback: "villa contemporary ocean breeze") }
      }
      internal enum Garden35 {
        /// Rustic country living paired with the peaceful rhythm of the tides.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-35.subtitle", fallback: "Rustic country living paired with the peaceful rhythm of the tides.") }
        /// backyard farmhouse ocean serenity
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-35.title", fallback: "backyard farmhouse ocean serenity") }
      }
      internal enum Garden36 {
        /// Sleek outdoor lines accented by a fresh, seasonal explosion of color.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-36.subtitle", fallback: "Sleek outdoor lines accented by a fresh, seasonal explosion of color.") }
        /// backyard contemporary spring bloom
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-36.title", fallback: "backyard contemporary spring bloom") }
      }
      internal enum Garden37 {
        /// Exotic greenery and clean design cooled by a salty, coastal wind.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-37.subtitle", fallback: "Exotic greenery and clean design cooled by a salty, coastal wind.") }
        /// backyard tropical modern ocean breeze
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-37.title", fallback: "backyard tropical modern ocean breeze") }
      }
      internal enum Garden38 {
        /// Clean, modern landscaping that merges seamlessly into a soft skyline.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-38.subtitle", fallback: "Clean, modern landscaping that merges seamlessly into a soft skyline.") }
        /// backyard contemporary gentle horizon
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-38.title", fallback: "backyard contemporary gentle horizon") }
      }
      internal enum Garden39 {
        /// Sun-drenched stonework set against the soft hues of the coastline.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-39.subtitle", fallback: "Sun-drenched stonework set against the soft hues of the coastline.") }
        /// courtyard mediterranean pastel shores
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-39.title", fallback: "courtyard mediterranean pastel shores") }
      }
      internal enum Garden40 {
        /// A sturdy, rural courtyard centered on natural weight and symmetry.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.garden-40.subtitle", fallback: "A sturdy, rural courtyard centered on natural weight and symmetry.") }
        /// courtyard farmhouse stone balance
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.garden-40.title", fallback: "courtyard farmhouse stone balance") }
      }
      internal enum Interior01 {
        /// A seamless fusion of nature and moody sophistication in a refined, organic space.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-01.subtitle", fallback: "A seamless fusion of nature and moody sophistication in a refined, organic space.") }
        /// attic biophilic dusky elegance
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-01.title", fallback: "attic biophilic dusky elegance") }
      }
      internal enum Interior02 {
        /// A high-end dining experience draped in deep reds and velvet-era glamour.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-02.subtitle", fallback: "A high-end dining experience draped in deep reds and velvet-era glamour.") }
        /// restaurant vintage crimson luxury
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-02.title", fallback: "restaurant vintage crimson luxury") }
      }
      internal enum Interior03 {
        /// Clean Nordic minimalism infused with a refreshing, luminous water-inspired tint.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-03.subtitle", fallback: "Clean Nordic minimalism infused with a refreshing, luminous water-inspired tint.") }
        /// bathroom scandinavian aqua glow
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-03.title", fallback: "bathroom scandinavian aqua glow") }
      }
      internal enum Interior04 {
        /// A lush, vibrant sanctuary of deep forest greens and exotic botanical flair.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-04.subtitle", fallback: "A lush, vibrant sanctuary of deep forest greens and exotic botanical flair.") }
        /// bathroom tropical emerald charm
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-04.title", fallback: "bathroom tropical emerald charm") }
      }
      internal enum Interior05 {
        /// An airy, salt-kissed retreat defined by light textures and ocean-inspired tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-05.subtitle", fallback: "An airy, salt-kissed retreat defined by light textures and ocean-inspired tones.") }
        /// bathroom coastal seaside breeze
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-05.title", fallback: "bathroom coastal seaside breeze") }
      }
      internal enum Interior06 {
        /// A drenching immersion of living greenery and natural, dappled light.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-06.subtitle", fallback: "A drenching immersion of living greenery and natural, dappled light.") }
        /// bathroom biophilic forest canopy
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-06.title", fallback: "bathroom biophilic forest canopy") }
      }
      internal enum Interior07 {
        /// Bold, eclectic layers of rich textures in a sophisticated, weathered violet.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-07.subtitle", fallback: "Bold, eclectic layers of rich textures in a sophisticated, weathered violet.") }
        /// bedroom maximalist faded plum
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-07.title", fallback: "bedroom maximalist faded plum") }
      }
      internal enum Interior08 {
        /// A high-tech library where digital tools meet lush, organic timber.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-08.subtitle", fallback: "A high-tech library where digital tools meet lush, organic timber.") }
        /// study room organic modern canopy
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-08.title", fallback: "study room organic modern canopy") }
      }
      internal enum Interior09 {
        /// High-tech edgy aesthetics met by vibrant, sugary-sweet synthetic glows.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-09.subtitle", fallback: "High-tech edgy aesthetics met by vibrant, sugary-sweet synthetic glows.") }
        /// bedroom cyberpunk neon sorbet
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-09.title", fallback: "bedroom cyberpunk neon sorbet") }
      }
      internal enum Interior10 {
        /// Free-spirited textures layered with soft, sunset-inspired warmth.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-10.subtitle", fallback: "Free-spirited textures layered with soft, sunset-inspired warmth.") }
        /// bedroom boho peach meadow
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-10.title", fallback: "bedroom boho peach meadow") }
      }
      internal enum Interior11 {
        /// Calm, functional minimalism accented by deep, seafaring blues.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-11.subtitle", fallback: "Calm, functional minimalism accented by deep, seafaring blues.") }
        /// study room japandi azure coast
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-11.title", fallback: "study room japandi azure coast") }
      }
      internal enum Interior12 {
        /// A professional suite defined by premium materials and rich, grounded colors.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-12.subtitle", fallback: "A professional suite defined by premium materials and rich, grounded colors.") }
        /// office luxury earthy hues
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-12.title", fallback: "office luxury earthy hues") }
      }
      internal enum Interior13 {
        /// A decadent pairing of rich metallic gold and deep, regal jewel-toned blue.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-13.subtitle", fallback: "A decadent pairing of rich metallic gold and deep, regal jewel-toned blue.") }
        /// dining room luxury golden sapphire
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-13.title", fallback: "dining room luxury golden sapphire") }
      }
      internal enum Interior14 {
        /// Harmonious Zen minimalism draped in warm, neutral desert tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-14.subtitle", fallback: "Harmonious Zen minimalism draped in warm, neutral desert tones.") }
        /// dining room japandi muted sands
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-14.title", fallback: "dining room japandi muted sands") }
      }
      internal enum Interior15 {
        /// A cozy, lived-in space celebrating weathered wood and nostalgic details.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-15.subtitle", fallback: "A cozy, lived-in space celebrating weathered wood and nostalgic details.") }
        /// dining room vintage rustic charm
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-15.title", fallback: "dining room vintage rustic charm") }
      }
      internal enum Interior16 {
        /// An explosion of pattern and texture lit by bright, fruity electric colors.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-16.subtitle", fallback: "An explosion of pattern and texture lit by bright, fruity electric colors.") }
        /// living room maximalist neon sorbet
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-16.title", fallback: "living room maximalist neon sorbet") }
      }
      internal enum Interior17 {
        /// Crisp, clean Nordic lines chilled by refreshing, frosty winter tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-17.subtitle", fallback: "Crisp, clean Nordic lines chilled by refreshing, frosty winter tones.") }
        /// living room scandinavian icy blues
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-17.title", fallback: "living room scandinavian icy blues") }
      }
      internal enum Interior18 {
        /// A breezy workspace warmed by late-season sun and cozy, fallen-leaf hues.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-18.subtitle", fallback: "A breezy workspace warmed by late-season sun and cozy, fallen-leaf hues.") }
        /// home office coastal autumn glow
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-18.title", fallback: "home office coastal autumn glow") }
      }
      internal enum Interior19 {
        /// Festive, understated elegance using neutral tones and subtle holiday warmth.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-19.subtitle", fallback: "Festive, understated elegance using neutral tones and subtle holiday warmth.") }
        /// home office christmas muted sands
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-19.title", fallback: "home office christmas muted sands") }
      }
      internal enum Interior20 {
        /// Iconic 1950s shapes anchored by deep, earthy orange and timber.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-20.subtitle", fallback: "Iconic 1950s shapes anchored by deep, earthy orange and timber.") }
        /// living room midcentury retro rust
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-20.title", fallback: "living room midcentury retro rust") }
      }
      internal enum Interior21 {
        /// A playful yet soft spectrum of colors flowing across a clean, modern layout.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-21.subtitle", fallback: "A playful yet soft spectrum of colors flowing across a clean, modern layout.") }
        /// kitchen rainbow gentle horizon
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-21.title", fallback: "kitchen rainbow gentle horizon") }
      }
      internal enum Interior22 {
        /// A grounded, chef-grade space highlighting raw timber and clay-inspired palettes.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-22.subtitle", fallback: "A grounded, chef-grade space highlighting raw timber and clay-inspired palettes.") }
        /// kitchen organic modern earthy tones
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-22.title", fallback: "kitchen organic modern earthy tones") }
      }
      internal enum Interior23 {
        /// A timeless mix of old and new defined by sophisticated, cool grey tones.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-23.subtitle", fallback: "A timeless mix of old and new defined by sophisticated, cool grey tones.") }
        /// kitchen transitional slate shades
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-23.title", fallback: "kitchen transitional slate shades") }
      }
      internal enum Interior24 {
        /// High-end finishes meet a warm, beachfront-inspired metallic radiance.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-24.subtitle", fallback: "High-end finishes meet a warm, beachfront-inspired metallic radiance.") }
        /// kitchen luxury golden shore
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-24.title", fallback: "kitchen luxury golden shore") }
      }
      internal enum Interior25 {
        /// Weathered country charm painted in dreamy, sunset pastel hues.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-25.subtitle", fallback: "Weathered country charm painted in dreamy, sunset pastel hues.") }
        /// living room rustic candy sky
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-25.title", fallback: "living room rustic candy sky") }
      }
      internal enum Interior26 {
        /// A soft, playful family space in sugary, matte-finished light colors.
        internal static var subtitle: String { L10n.tr("Localizable", "inspiration.item.interior-26.subtitle", fallback: "A soft, playful family space in sugary, matte-finished light colors.") }
        /// living room cute and kid frosted pastels
        internal static var title: String { L10n.tr("Localizable", "inspiration.item.interior-26.title", fallback: "living room cute and kid frosted pastels") }
      }
    }
  }
  internal enum InspirationFilter {
    /// All
    internal static var all: String { L10n.tr("Localizable", "inspiration_filter.all", fallback: "All") }
    /// Apply
    internal static var apply: String { L10n.tr("Localizable", "inspiration_filter.apply", fallback: "Apply") }
    /// EXTERIOR SPACES
    internal static var exteriorSpaces: String { L10n.tr("Localizable", "inspiration_filter.exterior_spaces", fallback: "EXTERIOR SPACES") }
    /// FAVOURITE
    internal static var favourite: String { L10n.tr("Localizable", "inspiration_filter.favourite", fallback: "FAVOURITE") }
    /// FEATURES
    internal static var features: String { L10n.tr("Localizable", "inspiration_filter.features", fallback: "FEATURES") }
    /// GARDEN SPACES
    internal static var gardenSpaces: String { L10n.tr("Localizable", "inspiration_filter.garden_spaces", fallback: "GARDEN SPACES") }
    /// INTERIOR SPACES
    internal static var interiorSpaces: String { L10n.tr("Localizable", "inspiration_filter.interior_spaces", fallback: "INTERIOR SPACES") }
    /// Liked
    internal static var liked: String { L10n.tr("Localizable", "inspiration_filter.liked", fallback: "Liked") }
    /// OTHER SPACES
    internal static var otherSpaces: String { L10n.tr("Localizable", "inspiration_filter.other_spaces", fallback: "OTHER SPACES") }
    /// Reset
    internal static var reset: String { L10n.tr("Localizable", "inspiration_filter.reset", fallback: "Reset") }
    /// Filters
    internal static var title: String { L10n.tr("Localizable", "inspiration_filter.title", fallback: "Filters") }
    internal enum Feature {
      /// Edit
      internal static var edit: String { L10n.tr("Localizable", "inspiration_filter.feature.edit", fallback: "Edit") }
      /// Furniture Finder
      internal static var furnitureFinder: String { L10n.tr("Localizable", "inspiration_filter.feature.furniture_finder", fallback: "Furniture Finder") }
      /// Interior Redesign
      internal static var interiorRedesign: String { L10n.tr("Localizable", "inspiration_filter.feature.interior_redesign", fallback: "Interior Redesign") }
    }
    internal enum Space {
      /// Backyard
      internal static var backyard: String { L10n.tr("Localizable", "inspiration_filter.space.backyard", fallback: "Backyard") }
      /// Bathroom
      internal static var bathroom: String { L10n.tr("Localizable", "inspiration_filter.space.bathroom", fallback: "Bathroom") }
      /// Bedroom
      internal static var bedroom: String { L10n.tr("Localizable", "inspiration_filter.space.bedroom", fallback: "Bedroom") }
      /// Courtyard
      internal static var courtyard: String { L10n.tr("Localizable", "inspiration_filter.space.courtyard", fallback: "Courtyard") }
      /// Garden
      internal static var garden: String { L10n.tr("Localizable", "inspiration_filter.space.garden", fallback: "Garden") }
      /// Kitchen
      internal static var kitchen: String { L10n.tr("Localizable", "inspiration_filter.space.kitchen", fallback: "Kitchen") }
      /// Living room
      internal static var livingRoom: String { L10n.tr("Localizable", "inspiration_filter.space.living_room", fallback: "Living room") }
      /// Pool
      internal static var pool: String { L10n.tr("Localizable", "inspiration_filter.space.pool", fallback: "Pool") }
      /// Toilet
      internal static var toilet: String { L10n.tr("Localizable", "inspiration_filter.space.toilet", fallback: "Toilet") }
      /// Villa
      internal static var villa: String { L10n.tr("Localizable", "inspiration_filter.space.villa", fallback: "Villa") }
    }
  }
  internal enum Interior {
    internal enum CustomStyle {
      /// Apply
      internal static var apply: String { L10n.tr("Localizable", "interior.custom_style.apply", fallback: "Apply") }
      /// %d/150
      internal static func characterCount(_ p1: Int) -> String {
        return L10n.tr("Localizable", "interior.custom_style.character_count", p1, fallback: "%d/150")
      }
      /// Describe your dream interior style
      /// (e.g. Modern Japanese Zen with
      /// dark wood accents)...
      internal static var placeholder: String { L10n.tr("Localizable", "interior.custom_style.placeholder", fallback: "Describe your dream interior style\n(e.g. Modern Japanese Zen with\ndark wood accents)...") }
      /// Custom style popup
      internal static var title: String { L10n.tr("Localizable", "interior.custom_style.title", fallback: "Custom Style") }
    }
    internal enum DesignStyle {
      /// Art Deco
      internal static var artDeco: String { L10n.tr("Localizable", "interior.design_style.art_deco", fallback: "Art Deco") }
      /// Biophilic
      internal static var biophilic: String { L10n.tr("Localizable", "interior.design_style.biophilic", fallback: "Biophilic") }
      /// Brutalist
      internal static var brutalist: String { L10n.tr("Localizable", "interior.design_style.brutalist", fallback: "Brutalist") }
      /// Candy Land
      internal static var candyLand: String { L10n.tr("Localizable", "interior.design_style.candy_land", fallback: "Candy Land") }
      /// Christmas
      internal static var christmas: String { L10n.tr("Localizable", "interior.design_style.christmas", fallback: "Christmas") }
      /// Coastal
      internal static var coastal: String { L10n.tr("Localizable", "interior.design_style.coastal", fallback: "Coastal") }
      /// Contemporary
      internal static var contemporary: String { L10n.tr("Localizable", "interior.design_style.contemporary", fallback: "Contemporary") }
      /// Desert Modernism
      internal static var desertModernism: String { L10n.tr("Localizable", "interior.design_style.desert_modernism", fallback: "Desert Modernism") }
      /// Industrial
      internal static var industrial: String { L10n.tr("Localizable", "interior.design_style.industrial", fallback: "Industrial") }
      /// Japandi
      internal static var japandi: String { L10n.tr("Localizable", "interior.design_style.japandi", fallback: "Japandi") }
      /// Kids Room
      internal static var kidsRoom: String { L10n.tr("Localizable", "interior.design_style.kids_room", fallback: "Kids Room") }
      /// Luxurious
      internal static var luxurious: String { L10n.tr("Localizable", "interior.design_style.luxurious", fallback: "Luxurious") }
      /// Maximalist
      internal static var maximalist: String { L10n.tr("Localizable", "interior.design_style.maximalist", fallback: "Maximalist") }
      /// Mediterranean
      internal static var mediterranean: String { L10n.tr("Localizable", "interior.design_style.mediterranean", fallback: "Mediterranean") }
      /// Midcentury Modern
      internal static var midcenturyModern: String { L10n.tr("Localizable", "interior.design_style.midcentury_modern", fallback: "Midcentury Modern") }
      /// Minimalist
      internal static var minimalist: String { L10n.tr("Localizable", "interior.design_style.minimalist", fallback: "Minimalist") }
      /// Modern
      internal static var modern: String { L10n.tr("Localizable", "interior.design_style.modern", fallback: "Modern") }
      /// Modern Arabic
      internal static var modernArabic: String { L10n.tr("Localizable", "interior.design_style.modern_arabic", fallback: "Modern Arabic") }
      /// Modern Farm House
      internal static var modernFarmHouse: String { L10n.tr("Localizable", "interior.design_style.modern_farm_house", fallback: "Modern Farm House") }
      /// Neon
      internal static var neon: String { L10n.tr("Localizable", "interior.design_style.neon", fallback: "Neon") }
      /// No Style
      internal static var noStyle: String { L10n.tr("Localizable", "interior.design_style.no_style", fallback: "No Style") }
      /// Organic Modern
      internal static var organicModern: String { L10n.tr("Localizable", "interior.design_style.organic_modern", fallback: "Organic Modern") }
      /// Quiet Luxury
      internal static var quietLuxury: String { L10n.tr("Localizable", "interior.design_style.quiet_luxury", fallback: "Quiet Luxury") }
      /// Retro
      internal static var retro: String { L10n.tr("Localizable", "interior.design_style.retro", fallback: "Retro") }
      /// Rustic
      internal static var rustic: String { L10n.tr("Localizable", "interior.design_style.rustic", fallback: "Rustic") }
      /// Scandi Boho
      internal static var scandiBoho: String { L10n.tr("Localizable", "interior.design_style.scandi_boho", fallback: "Scandi Boho") }
      /// Scandinavian
      internal static var scandinavian: String { L10n.tr("Localizable", "interior.design_style.scandinavian", fallback: "Scandinavian") }
      /// Traditional
      internal static var traditional: String { L10n.tr("Localizable", "interior.design_style.traditional", fallback: "Traditional") }
      /// Tropical
      internal static var tropical: String { L10n.tr("Localizable", "interior.design_style.tropical", fallback: "Tropical") }
      /// Vintage Eclectic
      internal static var vintageEclectic: String { L10n.tr("Localizable", "interior.design_style.vintage_eclectic", fallback: "Vintage Eclectic") }
    }
    internal enum RoomType {
      /// Attic
      internal static var attic: String { L10n.tr("Localizable", "interior.room_type.attic", fallback: "Attic") }
      /// Balcony
      internal static var balcony: String { L10n.tr("Localizable", "interior.room_type.balcony", fallback: "Balcony") }
      /// Bathroom
      internal static var bathroom: String { L10n.tr("Localizable", "interior.room_type.bathroom", fallback: "Bathroom") }
      /// Bedroom
      internal static var bedroom: String { L10n.tr("Localizable", "interior.room_type.bedroom", fallback: "Bedroom") }
      /// Coffee Shop
      internal static var coffeeShop: String { L10n.tr("Localizable", "interior.room_type.coffee_shop", fallback: "Coffee Shop") }
      /// Interior flow UI terms
      internal static var diningRoom: String { L10n.tr("Localizable", "interior.room_type.dining_room", fallback: "Dining Room") }
      /// Gaming Room
      internal static var gamingRoom: String { L10n.tr("Localizable", "interior.room_type.gaming_room", fallback: "Gaming Room") }
      /// Home Office
      internal static var homeOffice: String { L10n.tr("Localizable", "interior.room_type.home_office", fallback: "Home Office") }
      /// Kitchen
      internal static var kitchen: String { L10n.tr("Localizable", "interior.room_type.kitchen", fallback: "Kitchen") }
      /// Living Room
      internal static var livingRoom: String { L10n.tr("Localizable", "interior.room_type.living_room", fallback: "Living Room") }
      /// Office
      internal static var office: String { L10n.tr("Localizable", "interior.room_type.office", fallback: "Office") }
      /// Restaurant
      internal static var restaurant: String { L10n.tr("Localizable", "interior.room_type.restaurant", fallback: "Restaurant") }
      /// Study Room
      internal static var studyRoom: String { L10n.tr("Localizable", "interior.room_type.study_room", fallback: "Study Room") }
    }
  }
  internal enum InteriorFlow {
    /// Pick a design style
    internal static var pickDesignStyle: String { L10n.tr("Localizable", "interior_flow.pick_design_style", fallback: "Pick a design style") }
    /// Pick a room type
    internal static var pickRoomType: String { L10n.tr("Localizable", "interior_flow.pick_room_type", fallback: "Pick a room type") }
  }
  internal enum Intervention {
    /// How much of the original layout should we keep?
    internal static var subtitle: String { L10n.tr("Localizable", "intervention.subtitle", fallback: "How much of the original layout should we keep?") }
    /// AI Intervention
    internal static var title: String { L10n.tr("Localizable", "intervention.title", fallback: "AI Intervention") }
    internal enum High {
      /// Creative redesign with high innovation, low preservation.
      internal static var description: String { L10n.tr("Localizable", "intervention.high.description", fallback: "Creative redesign with high innovation, low preservation.") }
      /// HIGH
      internal static var title: String { L10n.tr("Localizable", "intervention.high.title", fallback: "HIGH") }
    }
    internal enum Light {
      /// Layout decoration with only textures and furniture updates.
      internal static var description: String { L10n.tr("Localizable", "intervention.light.description", fallback: "Layout decoration with only textures and furniture updates.") }
      /// LIGHT
      internal static var title: String { L10n.tr("Localizable", "intervention.light.title", fallback: "LIGHT") }
    }
    internal enum Medium {
      /// Balanced redesign with key room elements preserved.
      internal static var description: String { L10n.tr("Localizable", "intervention.medium.description", fallback: "Balanced redesign with key room elements preserved.") }
      /// MEDIUM
      internal static var title: String { L10n.tr("Localizable", "intervention.medium.title", fallback: "MEDIUM") }
    }
  }
  internal enum Language {
    /// Arabic (Saudi Arabia)
    internal static var arabicSaudiArabia: String { L10n.tr("Localizable", "language.arabic_saudi_arabia", fallback: "Arabic (Saudi Arabia)") }
    /// English (US)
    internal static var englishUs: String { L10n.tr("Localizable", "language.english_us", fallback: "English (US)") }
    /// French (France)
    internal static var frenchFrance: String { L10n.tr("Localizable", "language.french_france", fallback: "French (France)") }
    /// German (Germany)
    internal static var germanGermany: String { L10n.tr("Localizable", "language.german_germany", fallback: "German (Germany)") }
    /// Hindi
    internal static var hindi: String { L10n.tr("Localizable", "language.hindi", fallback: "Hindi") }
    /// Indonesian
    internal static var indonesian: String { L10n.tr("Localizable", "language.indonesian", fallback: "Indonesian") }
    /// Italian
    internal static var italian: String { L10n.tr("Localizable", "language.italian", fallback: "Italian") }
    /// Japanese
    internal static var japanese: String { L10n.tr("Localizable", "language.japanese", fallback: "Japanese") }
    /// Korean
    internal static var korean: String { L10n.tr("Localizable", "language.korean", fallback: "Korean") }
    /// Malay
    internal static var malay: String { L10n.tr("Localizable", "language.malay", fallback: "Malay") }
    /// Portuguese (Brazil)
    internal static var portugueseBrazil: String { L10n.tr("Localizable", "language.portuguese_brazil", fallback: "Portuguese (Brazil)") }
    /// Russian
    internal static var russian: String { L10n.tr("Localizable", "language.russian", fallback: "Russian") }
    /// Save
    internal static var save: String { L10n.tr("Localizable", "language.save", fallback: "Save") }
    /// Spanish (Spain)
    internal static var spanishSpain: String { L10n.tr("Localizable", "language.spanish_spain", fallback: "Spanish (Spain)") }
    /// Thai
    internal static var thai: String { L10n.tr("Localizable", "language.thai", fallback: "Thai") }
    /// Language
    internal static var title: String { L10n.tr("Localizable", "language.title", fallback: "Language") }
    /// Turkish
    internal static var turkish: String { L10n.tr("Localizable", "language.turkish", fallback: "Turkish") }
  }
  internal enum Limit {
    /// Upgrade Now
    internal static var upgradeNow: String { L10n.tr("Localizable", "limit.upgrade_now", fallback: "Upgrade Now") }
    internal enum GenerationsLeft {
      /// Unlock unlimited features, designs &
      /// faster processing with Pro.
      internal static var message: String { L10n.tr("Localizable", "limit.generations_left.message", fallback: "Unlock unlimited features, designs &\nfaster processing with Pro.") }
      /// %d/%d Free
      /// Generations Left
      internal static func title(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "limit.generations_left.title", p1, p2, fallback: "%d/%d Free\nGenerations Left")
      }
    }
    internal enum Reached {
      /// You've used all your free generations.
      /// Unlock unlimited features, designs &
      /// faster processing with Pro.
      internal static var message: String { L10n.tr("Localizable", "limit.reached.message", fallback: "You've used all your free generations.\nUnlock unlimited features, designs &\nfaster processing with Pro.") }
      /// Limit Reached
      internal static var title: String { L10n.tr("Localizable", "limit.reached.title", fallback: "Limit Reached") }
    }
  }
  internal enum Onboarding {
    /// After
    internal static var after: String { L10n.tr("Localizable", "onboarding.after", fallback: "After") }
    /// Continue
    internal static var `continue`: String { L10n.tr("Localizable", "onboarding.continue", fallback: "Continue") }
    internal enum Exterior {
      /// Reimagine your facade
      internal static var subtitle: String { L10n.tr("Localizable", "onboarding.exterior.subtitle", fallback: "Reimagine your facade") }
      /// Exterior Design
      internal static var title: String { L10n.tr("Localizable", "onboarding.exterior.title", fallback: "Exterior Design") }
    }
    internal enum Interior {
      /// Redesign your space instantly
      internal static var subtitle: String { L10n.tr("Localizable", "onboarding.interior.subtitle", fallback: "Redesign your space instantly") }
      /// Interior Design
      internal static var title: String { L10n.tr("Localizable", "onboarding.interior.title", fallback: "Interior Design") }
    }
    internal enum Landscape {
      /// Refresh your garden with AI
      internal static var subtitle: String { L10n.tr("Localizable", "onboarding.landscape.subtitle", fallback: "Refresh your garden with AI") }
      /// Landscape Design
      internal static var title: String { L10n.tr("Localizable", "onboarding.landscape.title", fallback: "Landscape Design") }
    }
    internal enum TrialEnabled {
      /// Start Designing
      internal static var startDesigning: String { L10n.tr("Localizable", "onboarding.trial_enabled.start_designing", fallback: "Start Designing") }
      /// You now have full access to all premium features.
      internal static var subtitle: String { L10n.tr("Localizable", "onboarding.trial_enabled.subtitle", fallback: "You now have full access to all premium features.") }
      /// 3-day free trial is enabled!
      internal static var title: String { L10n.tr("Localizable", "onboarding.trial_enabled.title", fallback: "3-day free trial is enabled!") }
      /// 3-day free trial
      internal static var titleLine1: String { L10n.tr("Localizable", "onboarding.trial_enabled.title_line1", fallback: "3-day free trial") }
      /// is enabled!
      internal static var titleLine2: String { L10n.tr("Localizable", "onboarding.trial_enabled.title_line2", fallback: "is enabled!") }
    }
    internal enum Welcome {
      /// Get Started
      internal static var getStarted: String { L10n.tr("Localizable", "onboarding.welcome.get_started", fallback: "Get Started") }
      /// Privacy Policy
      internal static var privacyPolicy: String { L10n.tr("Localizable", "onboarding.welcome.privacy_policy", fallback: "Privacy Policy") }
      /// Subscription Terms
      internal static var subscriptionTerms: String { L10n.tr("Localizable", "onboarding.welcome.subscription_terms", fallback: "Subscription Terms") }
      /// Transform your space with AI
      internal static var subtitle: String { L10n.tr("Localizable", "onboarding.welcome.subtitle", fallback: "Transform your space with AI") }
      /// Terms of use
      internal static var termsOfUse: String { L10n.tr("Localizable", "onboarding.welcome.terms_of_use", fallback: "Terms of use") }
      /// Welcome to HomeGPT
      internal static var title: String { L10n.tr("Localizable", "onboarding.welcome.title", fallback: "Welcome to HomeGPT") }
      internal enum Terms {
        /// and
        internal static var and: String { L10n.tr("Localizable", "onboarding.welcome.terms.and", fallback: "and") }
        /// ,
        internal static var comma: String { L10n.tr("Localizable", "onboarding.welcome.terms.comma", fallback: ",") }
        /// By continuing, you agree with
        internal static var leading: String { L10n.tr("Localizable", "onboarding.welcome.terms.leading", fallback: "By continuing, you agree with") }
        /// along with our use of third-party tools for app functionality.
        internal static var thirdPartyTools: String { L10n.tr("Localizable", "onboarding.welcome.terms.third_party_tools", fallback: "along with our use of third-party tools for app functionality.") }
      }
    }
  }
  internal enum PhotoSource {
    /// Camera
    internal static var camera: String { L10n.tr("Localizable", "photo_source.camera", fallback: "Camera") }
    /// Gallery
    internal static var gallery: String { L10n.tr("Localizable", "photo_source.gallery", fallback: "Gallery") }
    /// Get Started
    internal static var getStarted: String { L10n.tr("Localizable", "photo_source.get_started", fallback: "Get Started") }
    /// Choose your photo.
    /// For better results, use a horizontal
    /// direction.
    internal static var instruction: String { L10n.tr("Localizable", "photo_source.instruction", fallback: "Choose your photo.\nFor better results, use a horizontal\ndirection.") }
    /// OR TRY A SAMPLE
    internal static var orTryASample: String { L10n.tr("Localizable", "photo_source.or_try_a_sample", fallback: "OR TRY A SAMPLE") }
    /// Try a sample
    internal static var tryASample: String { L10n.tr("Localizable", "photo_source.try_a_sample", fallback: "Try a sample") }
    internal enum CameraUnavailable {
      /// Camera is not available on this device.
      internal static var message: String { L10n.tr("Localizable", "photo_source.camera_unavailable.message", fallback: "Camera is not available on this device.") }
      /// Camera Unavailable
      internal static var title: String { L10n.tr("Localizable", "photo_source.camera_unavailable.title", fallback: "Camera Unavailable") }
    }
    internal enum Interior {
      /// GET STARTED
      internal static var cta: String { L10n.tr("Localizable", "photo_source.interior.cta", fallback: "GET STARTED") }
      /// Upload or select from template to try
      internal static var subtitle: String { L10n.tr("Localizable", "photo_source.interior.subtitle", fallback: "Upload or select from template to try") }
      /// Start with a photo
      internal static var title: String { L10n.tr("Localizable", "photo_source.interior.title", fallback: "Start with a photo") }
    }
  }
  internal enum PhotoTips {
    /// BAD EXAMPLES:
    internal static var badExamples: String { L10n.tr("Localizable", "photo_tips.bad_examples", fallback: "BAD EXAMPLES:") }
    /// **Bright Lighting:** Ensure the room is well-lit to eliminate shadows.
    internal static var brightLighting: String { L10n.tr("Localizable", "photo_tips.bright_lighting", fallback: "**Bright Lighting:** Ensure the room is well-lit to eliminate shadows.") }
    /// Close
    internal static var close: String { L10n.tr("Localizable", "photo_tips.close", fallback: "Close") }
    /// The file dimensions must be at least 512x512.
    internal static var fileDimensions: String { L10n.tr("Localizable", "photo_tips.file_dimensions", fallback: "The file dimensions must be at least 512x512.") }
    /// The file size must be less than 20 MB.
    internal static var fileSize: String { L10n.tr("Localizable", "photo_tips.file_size", fallback: "The file size must be less than 20 MB.") }
    /// GOOD EXAMPLES:
    internal static var goodExamples: String { L10n.tr("Localizable", "photo_tips.good_examples", fallback: "GOOD EXAMPLES:") }
    /// GOT IT
    internal static var gotIt: String { L10n.tr("Localizable", "photo_tips.got_it", fallback: "GOT IT") }
    /// **Landscape Mode:** Capture your image horizontally.
    internal static var landscapeMode: String { L10n.tr("Localizable", "photo_tips.landscape_mode", fallback: "**Landscape Mode:** Capture your image horizontally.") }
    /// FOR OPTIMAL RESULTS:
    internal static var optimalResults: String { L10n.tr("Localizable", "photo_tips.optimal_results", fallback: "FOR OPTIMAL RESULTS:") }
    /// REQUIREMENTS:
    internal static var requirements: String { L10n.tr("Localizable", "photo_tips.requirements", fallback: "REQUIREMENTS:") }
    /// **Stay Steady:** Keep the camera still for a sharp, detailed image.
    internal static var staySteady: String { L10n.tr("Localizable", "photo_tips.stay_steady", fallback: "**Stay Steady:** Keep the camera still for a sharp, detailed image.") }
    /// Photo Tips
    internal static var title: String { L10n.tr("Localizable", "photo_tips.title", fallback: "Photo Tips") }
    /// **Wide Framing:** Capture all key angles in a single frame.
    internal static var wideFraming: String { L10n.tr("Localizable", "photo_tips.wide_framing", fallback: "**Wide Framing:** Capture all key angles in a single frame.") }
  }
  internal enum Rating {
    /// Five star rating
    internal static var fiveStarRating: String { L10n.tr("Localizable", "rating.five_star_rating", fallback: "Five star rating") }
    /// Rate on App Store
    internal static var rateOnStore: String { L10n.tr("Localizable", "rating.rate_on_store", fallback: "Rate on App Store") }
    /// %d star rating
    internal static func starRating(_ p1: Int) -> String {
      return L10n.tr("Localizable", "rating.star_rating", p1, fallback: "%d star rating")
    }
    /// Write a Review
    internal static var writeReview: String { L10n.tr("Localizable", "rating.write_review", fallback: "Write a Review") }
    internal enum HomeEnjoyment {
      /// Rate your experience and help us build the future of AI home design. It only takes a second!
      internal static var message: String { L10n.tr("Localizable", "rating.home_enjoyment.message", fallback: "Rate your experience and help us build the future of AI home design. It only takes a second!") }
      /// Enjoying HomeGPT?
      internal static var title: String { L10n.tr("Localizable", "rating.home_enjoyment.title", fallback: "Enjoying HomeGPT?") }
    }
    internal enum ResultFeedback {
      /// We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you.
      internal static var message: String { L10n.tr("Localizable", "rating.result_feedback.message", fallback: "We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you.") }
      /// Your feedback =
      /// better designs
      internal static var title: String { L10n.tr("Localizable", "rating.result_feedback.title", fallback: "Your feedback =\nbetter designs") }
    }
  }
  internal enum Result {
    /// DOWNLOAD
    internal static var download: String { L10n.tr("Localizable", "result.download", fallback: "DOWNLOAD") }
    /// PRO
    internal static var pro: String { L10n.tr("Localizable", "result.pro", fallback: "PRO") }
    /// REGENERATE
    internal static var regenerate: String { L10n.tr("Localizable", "result.regenerate", fallback: "REGENERATE") }
    /// REMOVE WATERMARK
    internal static var removeWatermark: String { L10n.tr("Localizable", "result.remove_watermark", fallback: "REMOVE WATERMARK") }
    /// SAVE TO ARCHIVE
    internal static var saveToArchive: String { L10n.tr("Localizable", "result.save_to_archive", fallback: "SAVE TO ARCHIVE") }
    /// SHARE
    internal static var share: String { L10n.tr("Localizable", "result.share", fallback: "SHARE") }
    /// Result
    internal static var title: String { L10n.tr("Localizable", "result.title", fallback: "Result") }
    internal enum ArchiveSuccess {
      /// Saved to Archive
      internal static var title: String { L10n.tr("Localizable", "result.archive_success.title", fallback: "Saved to Archive") }
    }
    internal enum SaveFailure {
      /// The image could not be saved to your photo gallery.
      internal static var message: String { L10n.tr("Localizable", "result.save_failure.message", fallback: "The image could not be saved to your photo gallery.") }
      /// Photo library access is required to save this image.
      internal static var photoAccessRequired: String { L10n.tr("Localizable", "result.save_failure.photo_access_required", fallback: "Photo library access is required to save this image.") }
      /// Save Failed
      internal static var title: String { L10n.tr("Localizable", "result.save_failure.title", fallback: "Save Failed") }
    }
    internal enum SaveSuccess {
      /// The image has been saved to your photo gallery.
      internal static var message: String { L10n.tr("Localizable", "result.save_success.message", fallback: "The image has been saved to your photo gallery.") }
      /// Saved
      internal static var title: String { L10n.tr("Localizable", "result.save_success.title", fallback: "Saved") }
    }
  }
  internal enum Settings {
    /// Feedback
    internal static var feedback: String { L10n.tr("Localizable", "settings.feedback", fallback: "Feedback") }
    /// Language
    internal static var language: String { L10n.tr("Localizable", "settings.language", fallback: "Language") }
    /// Privacy Policy
    internal static var privacyPolicy: String { L10n.tr("Localizable", "settings.privacy_policy", fallback: "Privacy Policy") }
    /// Restore Purchase
    internal static var restorePurchase: String { L10n.tr("Localizable", "settings.restore_purchase", fallback: "Restore Purchase") }
    /// Restoring...
    internal static var restoring: String { L10n.tr("Localizable", "settings.restoring", fallback: "Restoring...") }
    /// Terms of Service
    internal static var termsOfService: String { L10n.tr("Localizable", "settings.terms_of_service", fallback: "Terms of Service") }
    /// Setting
    internal static var title: String { L10n.tr("Localizable", "settings.title", fallback: "Setting") }
    /// Version %@
    internal static func version(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), fallback: "Version %@")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static var bundle: Bundle {
    return LanguageManager.shared.currentBundle
  }
}
// swiftlint:enable convenience_type

