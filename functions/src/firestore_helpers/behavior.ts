const { initializeApp } = require('firebase-admin/app');
const functions = require("firebase-functions");
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
initializeApp();


const db = getFirestore();
db.settings({ ignoreUndefinedProperties: true });
export async function updateBehavior(id: string, data: any) {
    functions.logger.log('updateBehavior Type: ', typeof data);
    functions.logger.log('updateBehavior with ', data);
    if (typeof data === 'string') {
        console.log('is an string')
        data = JSON.parse(data)[0];
    }
    if (Array.isArray(data) && data?.length) {
        console.log('is an array')
        data = data[0];
    }
    let onlyTraitData = structuredClone(data);
    delete onlyTraitData.title;
    delete onlyTraitData.updated;
    delete onlyTraitData.created;
    // Flatten the data object
    const flattenedData = {
        id,
        title: data.title,
        mentions: data?.mentions,
        updated: Timestamp.now(),
        traitScores: { ...onlyTraitData },
    };
    await db.collection('behaviors').doc(id).update(flattenedData, { merge: true });
}