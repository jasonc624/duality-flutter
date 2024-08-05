// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
import {
    onDocumentCreated,
} from "firebase-functions/v2/firestore";
import { formatBehavior } from "./langchain_helpers";
import { deleteBehavior, updateBehavior } from "./firestore_helpers/behavior";

exports.behavior_added = onDocumentCreated("behaviors/{behaviorId}", async (event: any) => {
    const behaviorId = event.params.behaviorId;
    const snapshot = event.data;
    functions.logger.info("snapshot", snapshot);
    if (!snapshot) {
        functions.logger.info("No snapshot, skipping formatting");
        return null;
    }
    try {
        const formattedData = await formatBehavior(snapshot.data()).catch(async (error) => {
            functions.logger.error('failed at formatBehavior', error)
            //Somtimes the behavior wont be formatted due to saftey or perhaps throttling, so we delete it and user must try again
            await deleteBehavior(behaviorId);
            throw new functions.https.HttpsError("failed-precondition", error);
        });
        functions.logger.log('updating behavior with data', formattedData);
        return await updateBehavior(behaviorId, formattedData);
    } catch (error) {
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});

