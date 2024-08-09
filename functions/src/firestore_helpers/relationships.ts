const functions = require("firebase-functions");
const { getFirestore } = require('firebase-admin/firestore');

export type Relationship = {
    id: string;
    created: any;
    updated: any;
    type: string;
    name: string;
    profiles: string[];
    notes: string;
    tags: string[];
    metadata: any;
    current_standing: { emoji: string, summary: string };
}
export async function findExistingRelationship(mentions: string[], userId: string): Promise<Relationship[]> {
    const db = getFirestore();
    functions.logger.log('updateRelationship with userid', userId);
    const querySnapshot = await db.collection('users').doc(userId).collection('relationships')
        .where('tags', 'array-contains-any', mentions)
        .get();

    const relationships: any[] = [];
    querySnapshot.forEach((doc: any) => {
        relationships.push({
            id: doc?.id,
            ...doc.data()
        });
    });

    return relationships;
}

interface TraitScores {
    compassionate_callous?: number;
    honest_deceitful?: number;
    courageous_cowardly?: number;
    ambitious_lazy?: number;
    generous_greedy?: number;
    patient_impatient?: number;
    humble_arrogant?: number;
    loyal_disloyal?: number;
    optimistic_pessimistic?: number;
    responsible_irresponsible?: number;
}

// interface TraitReasons {
//     compassionate_callous_reason?: string;
//     honest_deceitful_reason?: string;
//     courageous_cowardly_reason?: string;
//     ambitious_lazy_reason?: string;
//     generous_greedy_reason?: string;
//     patient_impatient_reason?: string;
//     humble_arrogant_reason?: string;
//     loyal_disloyal_reason?: string;
//     optimistic_pessimistic_reason?: string;
//     responsible_irresponsible_reason?: string;
// }

interface Disorder {
    description?: string;
    name?: string;
    reason?: string;
    score?: number;
}

interface RelationshipMetadata {
    traitScores: TraitScores;
    disorders?: Disorder[];
}


export function updateBehaviorTraits(metadata: RelationshipMetadata | null, newTraits: TraitScores): RelationshipMetadata {
    const defaultTraitScores: TraitScores = {
        compassionate_callous: 0,
        honest_deceitful: 0,
        courageous_cowardly: 0,
        ambitious_lazy: 0,
        generous_greedy: 0,
        patient_impatient: 0,
        humble_arrogant: 0,
        loyal_disloyal: 0,
        optimistic_pessimistic: 0,
        responsible_irresponsible: 0
    };

    const updatedMetadata: RelationshipMetadata = {
        traitScores: metadata?.traitScores ?? { ...defaultTraitScores }
    };

    Object.entries(newTraits).forEach(([trait, value]) => {
        if (typeof value === 'number' && !trait.endsWith('_reason')) {
            const currentValue = updatedMetadata.traitScores[trait as keyof TraitScores] ?? 0;
            const newValue = currentValue + value;
            updatedMetadata.traitScores[trait as keyof TraitScores] = newValue;


            if (Math.abs(newValue) > 100) {
                functions.logger.warn(`High trait score detected: ${trait} = ${newValue}`);
            }
        }
    });

    functions.logger.log('updateBehaviorTraits result:', updatedMetadata);
    return updatedMetadata;
}

export function undoBehaviorTraits(metadata: RelationshipMetadata | null, traitsToUndo: TraitScores): RelationshipMetadata {
    if (!metadata || !metadata.traitScores) {
        // If there's no metadata or trait scores, return an empty metadata object
        return { traitScores: {} };
    }

    const updatedMetadata: RelationshipMetadata = {
        traitScores: { ...metadata.traitScores }
    };

    Object.entries(traitsToUndo).forEach(([trait, value]) => {
        if (typeof value === 'number' && !trait.endsWith('_reason')) {
            const currentValue = updatedMetadata.traitScores[trait as keyof TraitScores] ?? 0;
            const newValue = currentValue - value; // Subtract instead of add
            updatedMetadata.traitScores[trait as keyof TraitScores] = newValue;


            if (Math.abs(newValue) > 100) {  // Example threshold
                console.warn(`High trait score detected after undo: ${trait} = ${newValue}`);
            }
        }
    });

    console.log('undoBehaviorTraits result:', updatedMetadata);
    return updatedMetadata;
}