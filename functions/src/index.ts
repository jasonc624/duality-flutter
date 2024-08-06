// import { DocumentData } from "firebase-admin/firestore";
const functions = require("firebase-functions");
import {
    onDocumentCreated,
} from "firebase-functions/v2/firestore";
import { formatBehavior } from "./langchain_helpers";
import { Behavior, deleteBehavior, updateBehavior } from "./firestore_helpers/behavior";
import { findExistingRelationship, Relationship, updateBehaviorTraits } from "./firestore_helpers/relationships";
import { Timestamp } from "firebase-admin/firestore";
const { getFirestore } = require('firebase-admin/firestore');

exports.behavior_added = onDocumentCreated("behaviors/{behaviorId}", async (event: any) => {
    const db = getFirestore();
    const behaviorId = event.params.behaviorId;
    const snapshot = event.data;
    functions.logger.info("snapshot", snapshot.data());
    if (!snapshot) {
        functions.logger.info("No snapshot, skipping formatting");
        return null;
    }
    try {
        const formattedData: any = await formatBehavior(snapshot.data()).catch(async (error) => {
            functions.logger.error('failed at formatBehavior', error)
            //Somtimes the behavior wont be formatted due to saftey or perhaps throttling, so we delete it and user must try again
            await deleteBehavior(behaviorId);
            throw new functions.https.HttpsError("failed-precondition", error);
        });
        if (!formattedData) {
            await deleteBehavior(behaviorId);
            throw new Error('Formatted data is undefined');
        }

        const userDocRef = await db.collection('users').doc(snapshot.data().userRef);
        const userDoc = await userDocRef.get()
        const userData = userDoc.data();
        functions.logger.log('Is User Data defined?', !!userData);

        if (!userData) {
            throw new Error('User data is undefined');
        }
        // Update the behavior document with new data
        const updatedData: Behavior = await updateBehavior(behaviorId, formattedData);
        if (updatedData?.mentions && updatedData?.mentions?.length > 0) {
            // Find existing relationships with the mentioned users
            const existingRelationships: Relationship[] = await findExistingRelationship(updatedData?.mentions, userData.uid);
            if (existingRelationships.length) {
                functions.logger.log('Found existing relationships', existingRelationships);
                existingRelationships.forEach(async (relationship: Relationship) => {
                    // Look at existing relationship metadata and update the scores
                    const newMetadata = updateBehaviorTraits(relationship?.metadata, updatedData.traitScores);
                    userDocRef.collection('relationships').doc(relationship.id).update({
                        metadata: newMetadata
                    }, { merge: true });
                });
            } else {
                functions.logger.log('No existing relationships found');
                const lastSelectedProfileId = userData?.last_selected_profile;
                functions.logger.log('lastSelectedProfileId', lastSelectedProfileId);
                const profilesArr = lastSelectedProfileId ? [lastSelectedProfileId] : [];
                functions.logger.log('mentions to loop over', updatedData?.mentions);
                updatedData?.mentions.forEach(async (mention: string) => {
                    const collectionRef = await db.collection('users').doc(snapshot.data().userRef).collection('relationships');
                    const newRelationshipRef = collectionRef.doc();
                    // Create a new relationship
                    const newRelationship: any = {
                        id: newRelationshipRef.id,
                        createdAt: Timestamp.now(),
                        updatedAt: Timestamp.now(),
                        type: 'unknown',
                        name: mention,
                        profiles: profilesArr,
                        notes: formattedData.description,
                        tags: [mention],
                        metadata: updateBehaviorTraits(null, updatedData.traitScores),
                        current_standing: { emoji: '', summary: 'No summary yet.' }
                    };
                    await collectionRef.doc(newRelationship.id).set(newRelationship);
                });

            }
        }
        return updatedData;
    } catch (error) {
        functions.logger.error('Error in behavior_added function:', error);
        throw new functions.https.HttpsError("failed-precondition", error);
    }
});

