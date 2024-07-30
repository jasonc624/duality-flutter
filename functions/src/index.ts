// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
import {
    onDocumentWritten,
} from "firebase-functions/v2/firestore";

exports.behavior_written = onDocumentWritten("behaviors/{behaviorId}", (event: any) => {
    const behaviorId = event.params.behaviorId;
    const before = event.data.before.data()
    const after = event.data.after.data()
    try {
        functions.logger.info("behavior_written", behaviorId);
        functions.logger.info("before", before);
        functions.logger.info("after", after);
    } catch (error) {
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});
