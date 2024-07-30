import { DocumentData } from "firebase-admin/firestore";
import {
    onDocumentWritten,
    Change,
    FirestoreEvent
} from "firebase-functions/v2/firestore";

exports.behavior_written = onDocumentWritten("behaviors/{behaviorId}", (event) => {
    const behaviorId = event.params.behaviorId;
});