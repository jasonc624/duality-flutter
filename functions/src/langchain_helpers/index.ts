const functions = require('firebase-functions');

import { FunctionDeclarationSchemaType, GoogleGenerativeAI } from "@google/generative-ai";
import { Behavior } from "../firestore_helpers/behavior";
import { Relationship } from "../firestore_helpers/relationships";
const genAI = new GoogleGenerativeAI("AIzaSyDlP77_zfPOixhygxfqCrcQM5q2LJHckAY");


export async function formatBehavior(behavior: Behavior): Promise<[]> {
    functions.logger.log('Behavior to format:', behavior);
    const behaviorText = behavior?.description;
    // const safe: any[] = [


    //     {
    //         "category": "HARM_CATEGORY_HARASSMENT",
    //         "threshold": "BLOCK_NONE",
    //     },
    //     {
    //         "category": "HARM_CATEGORY_HATE_SPEECH",
    //         "threshold": "BLOCK_NONE",
    //     },
    //     {
    //         "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
    //         "threshold": "BLOCK_NONE",
    //     },
    //     {
    //         "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
    //         "threshold": "BLOCK_NONE",
    //     },
    // ]
    functions.logger.log(behaviorText);
    const model = genAI.getGenerativeModel({
        model: "gemini-1.5-flash",
        generationConfig: {
            responseMimeType: "application/json",
            responseSchema: {
                type: FunctionDeclarationSchemaType.ARRAY,
                items: {
                    type: FunctionDeclarationSchemaType.OBJECT,
                    properties: {
                        title: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        mentions: {
                            type: FunctionDeclarationSchemaType.ARRAY,
                            items: {
                                type: FunctionDeclarationSchemaType.STRING,
                                properties: {

                                }
                            }
                        },
                        disorders: {
                            type: FunctionDeclarationSchemaType.ARRAY,
                            items: {
                                type: FunctionDeclarationSchemaType.OBJECT,
                                properties: {
                                    description: {
                                        type: FunctionDeclarationSchemaType.STRING,
                                    },
                                    name: {
                                        type: FunctionDeclarationSchemaType.STRING,
                                    },
                                    reason: {
                                        type: FunctionDeclarationSchemaType.STRING,
                                    },
                                    score: {
                                        type: FunctionDeclarationSchemaType.NUMBER,
                                    },
                                }
                            }
                        },
                        suggestion: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        compassionate_callous: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        compassionate_callous_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        honest_deceitful: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        honest_deceitful_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        courageous_cowardly: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        courageous_cowardly_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        ambitious_lazy: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        ambitious_lazy_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        generous_greedy: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        generous_greedy_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        patient_impatient: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        patient_impatient_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        humble_arrogant: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        humble_arrogant_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        loyal_disloyal: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        loyal_disloyal_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        optimistic_pessimistic: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        optimistic_pessimistic_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        responsible_irresponsible: {
                            type: FunctionDeclarationSchemaType.NUMBER,
                        },
                        responsible_irresponsible_reason: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                    },
                },
            },
        }
    });
    let prompt = `Analyze the following behavior: "${behaviorText}"

    1. Provide a concise title that summarizes the behavior , not longer than 14 words. The behavior is being given to you by the user in the first person.
    
    2. Generate a list of personality traits in schema associated with this behavior. For each trait:
       a) Assign a score between -5 and 5, where:
          - Negative scores (-5 to -1) indicate negative aspects - Only give the full score amount when the action affects another person.
          - Zero (0) indicates a neutral aspect
          - Positive scores (1 to 5) indicate positive aspects - Only give the full score amount when the action affects another person.
       b) Provide a brief explanation for the assigned score.
    3. If the description contains any mentions of specific person by name or association (dad, friend, neighbor, supervisor etc), provide them as a string array. However you must not analyze the person mentioned.
    4. For any score less than 4, provide a suggestion for how to improve the behavior.
    5. Sometimes the behavior can be suggestive of a personality disorder. For this give a score from 1 - 5 if it meets any of these disorders:
        a) Cluster A (Odd or Eccentric Disorders)
            Paranoid Personality Disorder
            Schizoid Personality Disorder
            Schizotypal Personality Disorder
        b) Cluster B (Dramatic, Emotional, or Erratic Disorders)
            Antisocial Personality Disorder
            Borderline Personality Disorder
            Histrionic Personality Disorder
            Narcissistic Personality Disorder
        c) Cluster C (Anxious or Fearful Disorders)
            Avoidant Personality Disorder
            Dependent Personality Disorder
            Obsessive-Compulsive Personality Disorder
    `;
    let result = await model.generateContent(prompt)
    functions.logger.log("Format Behavior Result:", result.response.text());
    return JSON.parse(result.response.text());
}

export async function formatRelationship(relationship: Relationship): Promise<{ emoji: string, summary: string }> {
    functions.logger.log(relationship);
    if (!relationship.metadata?.traitScores) {
        functions.logger.error('No trait scores found, returning default');
        return { emoji: '', summary: '' };
    }
    const model = genAI.getGenerativeModel({
        model: "gemini-1.5-flash",
        generationConfig: {
            responseMimeType: "application/json",
            responseSchema: {
                type: FunctionDeclarationSchemaType.ARRAY,
                items: {
                    type: FunctionDeclarationSchemaType.OBJECT,
                    properties: {
                        emoji: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                        summary: {
                            type: FunctionDeclarationSchemaType.STRING,
                        },
                    },
                },
            },
        }
    });
    functions.logger.log('scores to analyze relationship on =>', relationship.metadata.traitScores);
    let prompt = `
    Parameters:
    - Higher positive scores indicate more positive behaviors.
    - Higher negative scores indicate more negative behaviors.
    - 0 Indicates neutral and does not affect the overall score.
    - The traits are paired as follows (positive_negative):
      1. compassionate_callous
      2. honest_deceitful
      3. courageous_cowardly
      4. ambitious_lazy
      5. generous_greedy
      6. patient_impatient
      7. humble_arrogant
      8. loyal_disloyal
      9. optimistic_pessimistic
      10. responsible_irresponsible
    
    Provide a concise summary (maximum 100 words) of the overall relationship dynamics from the perspective of the person that has the relationship with ${relationship.name}. 
    Consider the balance between positive and negative behaviors, giving appropriate weight to each trait. 
    Ensure your summary accurately reflects whether the relationship is predominantly positive, negative, or mixed based on the scores.
    Remember these trait scores are sum values of negative and positive behaviors that were done by the user towards the person in relationship.
    The concept of relationship is not always romantic and can be any type of relationship family, friend, colleague, etc.
    
    Also, select one emoji that best represents the relationship's overall tone from the following options:
    smile, proud, sad, angry, funny, fearful, bothered, romantic, neglected, worried, liar, muscle
    
    Format your response as:
    Summary: [Your 100-word analysis]
    Emoji: [Selected emoji]

    Analyze the relationship with ${relationship.name} based on the following aggregated personality trait scores:
    ${relationship.metadata.traitScores}
    `;
    let result = await model.generateContent(prompt)
    functions.logger.log("Format Relationship Result:", result.response.text());
    return JSON.parse(result.response.text())[0];
}

