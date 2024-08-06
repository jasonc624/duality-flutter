"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
const firestore_1 = require("firebase-functions/v2/firestore");
const langchain_helpers_1 = require("./langchain_helpers");
const behavior_1 = require("./firestore_helpers/behavior");
const relationships_1 = require("./firestore_helpers/relationships");
const firestore_2 = require("firebase-admin/firestore");
const { getFirestore } = require('firebase-admin/firestore');
exports.behavior_added = (0, firestore_1.onDocumentCreated)("behaviors/{behaviorId}", async (event) => {
    var _a;
    const db = getFirestore();
    const behaviorId = event.params.behaviorId;
    const snapshot = event.data;
    functions.logger.info("snapshot", snapshot.data());
    if (!snapshot) {
        functions.logger.info("No snapshot, skipping formatting");
        return null;
    }
    try {
        const formattedData = await (0, langchain_helpers_1.formatBehavior)(snapshot.data()).catch(async (error) => {
            functions.logger.error('failed at formatBehavior', error);
            //Somtimes the behavior wont be formatted due to saftey or perhaps throttling, so we delete it and user must try again
            await (0, behavior_1.deleteBehavior)(behaviorId);
            throw new functions.https.HttpsError("failed-precondition", error);
        });
        const userDocRef = await db.collection('users').doc(snapshot.data().userRef);
        const userDoc = await userDocRef.get();
        const userData = userDoc.data();
        functions.logger.log('Is User Data defined?', userData);
        const updatedData = await (0, behavior_1.updateBehavior)(behaviorId, formattedData);
        if ((updatedData === null || updatedData === void 0 ? void 0 : updatedData.mentions) && ((_a = updatedData === null || updatedData === void 0 ? void 0 : updatedData.mentions) === null || _a === void 0 ? void 0 : _a.length)) {
            // Find existing relationships with the mentioned users
            const existingRelationships = await (0, relationships_1.findExistingRelationship)(updatedData === null || updatedData === void 0 ? void 0 : updatedData.mentions, userData.uid);
            if (existingRelationships.length) {
                functions.logger.log('Found existing relationships', existingRelationships);
                existingRelationships.forEach(async (relationship) => {
                    // Look at existing relationship metadata and update the scores
                    const newMetadata = (0, relationships_1.updateBehaviorTraits)((relationship === null || relationship === void 0 ? void 0 : relationship.metadata) || null, formattedData.traitScores);
                    userDocRef.collection('relationships').doc(relationship.id).update({
                        metadata: newMetadata
                    }, { merge: true });
                });
            }
            else {
                functions.logger.log('No existing relationships found');
                const lastSelectedProfileId = userData === null || userData === void 0 ? void 0 : userData.last_selected_profile;
                functions.logger.log('lastSelectedProfileId', lastSelectedProfileId);
                // const profileRef = await userDocRef.collection('profiles').doc(lastSelectedProfileId).get();
                const profilesArr = lastSelectedProfileId ? [lastSelectedProfileId] : [];
                //  Create a new relationship for each mention
                // TOOD: Add check to see if user wants new relationships to be created for them.
                functions.logger.log('mentions to loop over', updatedData === null || updatedData === void 0 ? void 0 : updatedData.mentions);
                updatedData === null || updatedData === void 0 ? void 0 : updatedData.mentions.forEach(async (mention) => {
                    const collectionRef = await db.collection('users').doc(snapshot.data().userRef).collection('relationships');
                    const newRelationshipRef = collectionRef.doc();
                    // Create a new relationship
                    const newRelationship = {
                        id: newRelationshipRef.id,
                        created: firestore_2.Timestamp.now(),
                        updated: firestore_2.Timestamp.now(),
                        type: 'unknown',
                        name: mention,
                        profiles: profilesArr,
                        notes: formattedData.description,
                        tags: formattedData.mentions,
                        metadata: (0, relationships_1.updateBehaviorTraits)(null, formattedData.traitScores),
                        current_standing: { emoji: '', summary: 'No summary yet.' }
                    };
                    await collectionRef.doc(newRelationship.id).set(newRelationship);
                });
            }
        }
        return updatedData;
    }
    catch (error) {
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});
//# sourceMappingURL=index.js.map