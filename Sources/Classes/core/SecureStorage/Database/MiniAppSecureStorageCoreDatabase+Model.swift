import Foundation
import CoreData

@objc(SecureStorageEntry)
public final class SecureStorageEntry: NSManagedObject {

    @NSManaged var key: String
    @NSManaged var value: String

    public override var description: String {
        return "SecureStorageEntry"
    }

    static func entityDescription() -> NSEntityDescription {

        let entity = NSEntityDescription()
        entity.name = "SecureStorageEntry"
        entity.managedObjectClassName = "SecureStorageEntry"

        let keyAttr = NSAttributeDescription()
        keyAttr.name = "key"
        keyAttr.attributeType = .stringAttributeType
        keyAttr.isOptional = false

        let valueAttr = NSAttributeDescription()
        valueAttr.name = "value"
        valueAttr.attributeType = .stringAttributeType
        valueAttr.isOptional = false

        entity.properties = [keyAttr, valueAttr]

        return entity
    }

    static func managedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [entityDescription()]
        return model
    }
}
