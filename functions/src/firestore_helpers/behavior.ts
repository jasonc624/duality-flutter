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
    let onlyDisorders = structuredClone(onlyTraitData.disorders);
    let onlyEnvironmental = structuredClone(onlyTraitData.environmental);
    delete onlyTraitData.environmental;
    delete onlyTraitData.disorders;
    delete onlyTraitData.title;
    delete onlyTraitData.updated;
    delete onlyTraitData.created;
    delete onlyTraitData.mentions;
    delete onlyTraitData.suggestion;
    delete onlyTraitData.overall_score;
    if (data.mentions && data.mentions.length) {
        data.mentions = normalizeMentions(data.mentions);
    }
    // Flatten the data object
    const flattenedData = {
        id,
        description: data.description,
        title: data.title,
        mentions: data?.mentions,
        suggestion: data?.suggestion,
        overall_score: data?.overall_score,
        updated: Timestamp.now(),
        traitScores: { ...onlyTraitData },
        disorders: onlyDisorders,
        environmental: onlyEnvironmental
    };
    await db.collection('behaviors').doc(id).update(flattenedData, { merge: true });
    return flattenedData;
}
export async function deleteBehavior(id: string): Promise<any> {
    await db.collection('behaviors').doc(id).delete();
}

function normalizeMentions(mentions: string[]): string[] {
    // Convert to lowercase and remove duplicates
    return [...new Set(mentions.map(mention => mention.toLowerCase()))];
}

export type Behavior = {
    id: string;
    created?: any;
    updated: any;
    title?: string;
    description: string;
    suggestion?: string;
    overall_score: number;
    traitScores: any;
    mentions?: string[];
    disorders?: any[];
}