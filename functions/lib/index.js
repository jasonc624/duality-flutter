"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
const firestore_1 = require("firebase-functions/v2/firestore");
const langchain_helpers_1 = require("./langchain_helpers");
const behavior_1 = require("./firestore_helpers/behavior");
exports.behavior_written = (0, firestore_1.onDocumentWritten)("behaviors/{behaviorId}", async (event) => {
    var _a, _b, _c, _d, _e;
    const behaviorId = event.params.behaviorId;
    functions.logger.info("event", event);
    const before = (_b = (_a = event === null || event === void 0 ? void 0 : event.data) === null || _a === void 0 ? void 0 : _a.before) === null || _b === void 0 ? void 0 : _b.data();
    const after = (_d = (_c = event === null || event === void 0 ? void 0 : event.data) === null || _c === void 0 ? void 0 : _c.after) === null || _d === void 0 ? void 0 : _d.data();
    const id = (_e = event === null || event === void 0 ? void 0 : event.params) === null || _e === void 0 ? void 0 : _e.behaviorId;
    // Helper function to deep compare objects
    function isEqualExceptUpdated(obj1, obj2) {
        const keys1 = Object.keys(obj1).filter(key => key !== 'updated');
        const keys2 = Object.keys(obj2).filter(key => key !== 'updated');
        if (keys1.length !== keys2.length)
            return false;
        for (let key of keys1) {
            if (key === 'updated')
                continue;
            const val1 = obj1[key];
            const val2 = obj2[key];
            if (typeof val1 === 'object' && val1 !== null && typeof val2 === 'object' && val2 !== null) {
                if (!isEqualExceptUpdated(val1, val2))
                    return false;
            }
            else if (val1 !== val2) {
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
            const formattedData = await (0, langchain_helpers_1.formatBehavior)(after);
            functions.logger.log('formattedData', formattedData);
            functions.logger.log('data type', typeof formattedData);
            // Check if formatted data is different from the current data
            if (!isEqualExceptUpdated(after, formattedData)) {
                functions.logger.log('updating behavior');
                return await (0, behavior_1.updateBehavior)(id, formattedData);
            }
            else {
                functions.logger.info("No changes detected, skipping update");
                return null;
            }
        }
        else {
            functions.logger.info("No changes or document deleted, skipping update");
            return null;
        }
    }
    catch (error) {
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});
//# sourceMappingURL=index.js.map