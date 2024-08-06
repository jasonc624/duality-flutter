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
    current_standing: any;
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
    functions.logger.log('updateBehaviorTraits', metadata, newTraits);
    if (metadata === null) {
        metadata = {
            traitScores: {
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
            }
        };
    }
    const updatedMetadata = { ...metadata };
    functions.logger.log('updatedMetadata', updatedMetadata);
    if (!updatedMetadata?.traitScores) {
        updatedMetadata.traitScores = {
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
        }
    }

    for (const [trait, value] of Object.entries(newTraits)) {
        if (value !== undefined && !trait.endsWith('_reason')) {
            const currentValue = updatedMetadata.traitScores[trait as keyof TraitScores] || 0;
            let newValue = currentValue + value;

            // Ensure the value stays within -5 to 5 range
            newValue = Math.max(-5, Math.min(5, newValue));

            updatedMetadata.traitScores[trait as keyof TraitScores] = newValue;
        }
    }
    functions.logger.log('returning', updatedMetadata);
    return updatedMetadata;
}