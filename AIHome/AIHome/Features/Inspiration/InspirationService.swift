import Foundation

protocol InspirationServiceProtocol {
    func getInspirations() -> [InspirationItem]
    func toggleLike(for id: String)
}

final class MockInspirationService: InspirationServiceProtocol {
    private var items: [InspirationItem] = InspirationData.items
    private let likesKey = "saved_likes_ids"

    init() {
        let savedLikes = UserDefaults.standard.stringArray(forKey: likesKey) ?? []
        for index in items.indices {
            if savedLikes.contains(items[index].id) {
                items[index].isLiked = true
            }
        }
    }

    func getInspirations() -> [InspirationItem] {
        items
    }

    func toggleLike(for id: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isLiked.toggle()
        saveLikes()
    }

    private func saveLikes() {
        let likedIds = items.filter { $0.isLiked }.map { $0.id }
        UserDefaults.standard.set(likedIds, forKey: likesKey)
    }
}

private enum InspirationData {
    static let items: [InspirationItem] = [
        item(1, .interior, "ATTIC", "BIOPHILIC", "attic biophilic dusky elegance", "A seamless fusion of nature and moody sophistication in a refined, organic space.", .medium),
        item(2, .interior, "RESTAURANT", "VINTAGE ELECTIC", "restaurant vintage crimson luxury", "A high-end dining experience draped in deep reds and velvet-era glamour.", .medium),
        item(3, .interior, "BATHROOM", "SCANDINAVIAN", "bathroom scandinavian aqua glow", "Clean Nordic minimalism infused with a refreshing, luminous water-inspired tint.", .medium),
        item(4, .interior, "BATHROOM", "TROPICAL", "bathroom tropical emerald charm", "A lush, vibrant sanctuary of deep forest greens and exotic botanical flair.", .high),
        item(5, .interior, "BATHROOM", "COASTAL", "bathroom coastal seaside breeze", "An airy, salt-kissed retreat defined by light textures and ocean-inspired tones.", .low),
        item(6, .interior, "BATHROOM", "BIOPHILIC", "bathroom biophilic forest canopy", "A drenching immersion of living greenery and natural, dappled light.", .medium),
        item(7, .interior, "BEDROOM", "MAXIMALIST", "bedroom maximalist faded plum", "Bold, eclectic layers of rich textures in a sophisticated, weathered violet.", .medium),
        item(8, .interior, "STUDY ROOM", "ORGANIC MODERN", "study room organic modern canopy", "A high-tech library where digital tools meet lush, organic timber.", .high),
        item(9, .interior, "BEDROOM", "CYBERPUNK", "bedroom cyberpunk neon sorbet", "High-tech edgy aesthetics met by vibrant, sugary-sweet synthetic glows.", .low),
        item(10, .interior, "BEDROOM", "SCANDI BOHO", "bedroom boho peach meadow", "Free-spirited textures layered with soft, sunset-inspired warmth.", .low),
        item(11, .interior, "STUDY ROOM", "JAPANDI", "study room japandi azure coast", "Calm, functional minimalism accented by deep, seafaring blues.", .medium),
        item(12, .interior, "OFFICE", "LUXURIOUS", "office luxury earthy hues", "A professional suite defined by premium materials and rich, grounded colors.", .high),
        item(13, .interior, "DINING ROOM", "LUXURIOUS", "dining room luxury golden sapphire", "A decadent pairing of rich metallic gold and deep, regal jewel-toned blue.", .medium),
        item(14, .interior, "DINING ROOM", "JAPANDI", "dining room japandi muted sands", "Harmonious Zen minimalism draped in warm, neutral desert tones.", .high),
        item(15, .interior, "DINING ROOM", "VINTAGE ELECTIC", "dining room vintage rustic charm", "A cozy, lived-in space celebrating weathered wood and nostalgic details.", .low),
        item(16, .interior, "LIVING ROOM", "MAXIMALIST", "living room maximalist neon sorbet", "An explosion of pattern and texture lit by bright, fruity electric colors.", .medium),
        item(17, .interior, "LIVING ROOM", "SCANDINAVIAN", "living room scandinavian icy blues", "Crisp, clean Nordic lines chilled by refreshing, frosty winter tones.", .high),
        item(18, .interior, "HOME OFFICE", "COASTAL", "home office coastal autumn glow", "A breezy workspace warmed by late-season sun and cozy, fallen-leaf hues.", .high),
        item(19, .interior, "HOME OFFICE", "CHRISTMAS", "home office christmas muted sands", "Festive, understated elegance using neutral tones and subtle holiday warmth.", .medium),
        item(20, .interior, "LIVING ROOM", "MIDCENTURY", "living room midcentury retro rust", "Iconic 1950s shapes anchored by deep, earthy orange and timber.", .medium),
        item(21, .interior, "KITCHEN", "RAINBOW", "kitchen rainbow gentle horizon", "A playful yet soft spectrum of colors flowing across a clean, modern layout.", .high),
        item(22, .interior, "KITCHEN", "ORGANIC MODERN", "kitchen organic modern earthy tones", "A grounded, chef-grade space highlighting raw timber and clay-inspired palettes.", .medium),
        item(23, .interior, "KITCHEN", "TRANSITIONAL", "kitchen transitional slate shades", "A timeless mix of old and new defined by sophisticated, cool grey tones.", .medium),
        item(24, .interior, "KITCHEN", "LUXURIOUS", "kitchen luxury golden shore", "High-end finishes meet a warm, beachfront-inspired metallic radiance.", .high),
        item(25, .interior, "LIVING ROOM", "RUSTIC", "living room rustic candy sky", "Weathered country charm painted in dreamy, sunset pastel hues.", .high),
        item(26, .interior, "LIVING ROOM", "KIDS ROOM", "living room cute and kid frosted pastels", "A soft, playful family space in sugary, matte-finished light colors.", .medium),

        item(27, .exterior, "BALCONY", "MODERN FARM HOUSE", "balcony modern farm house earthy tones", "A serene outdoor escape featuring natural timber and grounded, organic hues.", .medium),
        item(28, .exterior, "APARTMENT", "CENTURY", "apartment century woodland retreat", "Timeless architectural details tucked away in a lush, ancient forest.", .high),
        item(29, .exterior, "HOUSE", "MODERN", "house modern neutral sands", "Sharp, contemporary edges finished in warm, desert-inspired tones.", .high),
        item(30, .exterior, "RANCH", "ALFRESCO KITCHEN", "ranch alfresco kitchen peach meadow", "A breezy, sprawling layout bathed in warm, sunset-inspired tones.", .medium),
        item(31, .exterior, "RANCH", "MEDITERRANEAN", "ranch mediterranean sunny pastures", "Warm Mediterranean textures overlooking wide, sun-soaked fields.", .low),
        item(32, .exterior, "RESIDENTIAL", "TROPICAL MODERN", "residential tropical modern slate shades", "Lush tropical forms grounded by sophisticated, cool grey finishes.", .high),
        item(33, .exterior, "RETAIL", "BOHO", "retail boho refined blues", "Refined bohemian textures layered with calm, sophisticated blues.", .high),
        item(34, .exterior, "VILLA", "CONTEMPORARY", "villa contemporary ocean breeze", "Ultra-modern coastal luxury designed to breathe with the ocean air.", .medium),

        item(35, .garden, "BACKYARD", "FARMHOUSE", "backyard farmhouse ocean serenity", "Rustic country living paired with the peaceful rhythm of the tides.", .low),
        item(36, .garden, "BACKYARD", "CONTEMPORARY", "backyard contemporary spring bloom", "Sleek outdoor lines accented by a fresh, seasonal explosion of color.", .high),
        item(37, .garden, "BACKYARD", "TROPICAL MODERN", "backyard tropical modern ocean breeze", "Exotic greenery and clean design cooled by a salty, coastal wind.", .medium),
        item(38, .garden, "BACKYARD", "CONTEMPORARY", "backyard contemporary gentle horizon", "Clean, modern landscaping that merges seamlessly into a soft skyline.", .medium),
        item(39, .garden, "COURTYARD", "MEDITERRANEAN", "courtyard mediterranean pastel shores", "Sun-drenched stonework set against the soft hues of the coastline.", .high),
        item(40, .garden, "COURTYARD", "FARMHOUSE", "courtyard farmhouse stone balance", "A sturdy, rural courtyard centered on natural weight and symmetry.", .medium)
    ]

    private static func item(
        _ number: Int,
        _ category: InspirationCategory,
        _ spaceType: String,
        _ styleTag: String,
        _ title: String,
        _ subtitle: String,
        _ interventionLevel: InspirationInterventionLevel
    ) -> InspirationItem {
        let prefix = category.rawValue.lowercased()
        let paddedNumber = number < 10 ? "0\(number)" : "\(number)"

        return InspirationItem(
            id: "\(prefix)-\(paddedNumber)",
            category: category,
            spaceType: spaceType,
            styleTag: styleTag,
            beforeImageName: "\(prefix)_\(paddedNumber)_before",
            afterImageName: "\(prefix)_\(paddedNumber)_after",
            title: title,
            subtitle: subtitle,
            interventionLevel: interventionLevel,
            isLiked: false
        )
    }
}
