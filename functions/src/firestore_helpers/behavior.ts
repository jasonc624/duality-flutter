const { initializeApp } = require('firebase-admin/app');
const functions = require("firebase-functions");
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
initializeApp();

const db = getFirestore();

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
    // Flatten the data object
    const flattenedData = {
        id,
        updated: Timestamp.now(),
        ...data
    };

    // Remove any nested arrays
    delete flattenedData[0];

    await db.collection('behaviors').doc(id).update(flattenedData, { merge: true });
}