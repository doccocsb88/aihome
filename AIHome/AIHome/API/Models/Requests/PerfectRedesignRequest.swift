import Foundation

public struct PerfectRedesignRequest {
    public let image: HomeDesignsImageSource
    public let designType: DesignType
    public let aiIntervention: AIIntervention
    public let noDesign: Int
    public let designStyle: String
    public let roomType: String?
    public let houseAngle: String?
    public let gardenType: String?
    public let customInstruction: String?
    public let keepStructuralElement: Bool?
    
    public init(image: HomeDesignsImageSource, designType: DesignType, aiIntervention: AIIntervention, noDesign: Int, designStyle: String, roomType: String? = nil, houseAngle: String? = nil, gardenType: String? = nil, customInstruction: String? = nil, keepStructuralElement: Bool? = nil) {
        self.image = image
        self.designType = designType
        self.aiIntervention = aiIntervention
        self.noDesign = noDesign
        self.designStyle = designStyle
        self.roomType = roomType
        self.houseAngle = houseAngle
        self.gardenType = gardenType
        self.customInstruction = customInstruction
        self.keepStructuralElement = keepStructuralElement
    }
}

extension PerfectRedesignRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendField(name: "design_type", value: designType.rawValue)
        builder.appendField(name: "ai_intervention", value: aiIntervention.rawValue)
        builder.appendField(name: "no_design", value: "\\(noDesign)")
        builder.appendField(name: "design_style", value: designStyle)
        
        if let roomType = roomType {
            builder.appendField(name: "room_type", value: roomType)
        }
        if let houseAngle = houseAngle {
            builder.appendField(name: "house_angle", value: houseAngle)
        }
        if let gardenType = gardenType {
            builder.appendField(name: "garden_type", value: gardenType)
        }
        if let customInstruction = customInstruction {
            builder.appendField(name: "custom_instruction", value: customInstruction)
        }
        if let keepStructuralElement = keepStructuralElement {
            builder.appendField(name: "keep_structural_element", value: keepStructuralElement ? "true" : "false")
        }
    }
}
