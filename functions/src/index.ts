// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
import {
    onDocumentWritten,
} from "firebase-functions/v2/firestore";
import { formatBehavior } from "./langchain_helpers";
import { updateBehavior } from "./firestore_helpers/behavior";

exports.behavior_written = onDocumentWritten("behaviors/{behaviorId}", async (event: any) => {
    const behaviorId = event.params.behaviorId;
    functions.logger.info("event", event);
    const before = event?.data?.before?.data()
    const after = event?.data?.after?.data()
    const id = event?.params?.behaviorId;
    // Helper function to deep compare objects
    function isEqualExceptUpdated(obj1: any, obj2: any): boolean {
        const keys1 = Object.keys(obj1).filter(key => key !== 'updated');
        const keys2 = Object.keys(obj2).filter(key => key !== 'updated');

        if (keys1.length !== keys2.length) return false;

        for (let key of keys1) {
            if (key === 'updated') continue;

            const val1 = obj1[key];
            const val2 = obj2[key];

            if (typeof val1 === 'object' && val1 !== null && typeof val2 === 'object' && val2 !== null) {
                if (!isEqualExceptUpdated(val1, val2)) return false;
            } else if (val1 !== val2) {
                return false;
            }
        }

        return true;
    }

    try {
        functions.logger.info("behavior_written", behaviorId);
        functions.logger.info("before", before);
        functions.logger.info("after", after);

        if (after && (!before || !isEqualExceptUpdated(before, after))) {
            const formattedData = await formatBehavior(after);
            functions.logger.log('formattedData', formattedData);
            functions.logger.log('data type', typeof formattedData);

            // Check if formatted data is different from the current data
            if (!isEqualExceptUpdated(after, formattedData)) {
                functions.logger.log('updating behavior');
                return await updateBehavior(id, formattedData);
            } else {
                functions.logger.info("No changes detected, skipping update");
                return null;
            }
        } else {
            functions.logger.info("No changes or document deleted, skipping update");
            return null;
        }
    } catch (error) {
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});

