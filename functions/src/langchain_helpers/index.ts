const functions = require('firebase-functions');
import { FunctionDeclarationSchemaType, GoogleGenerativeAI } from "@google/generative-ai";
const genAI = new GoogleGenerativeAI("AIzaSyDlP77_zfPOixhygxfqCrcQM5q2LJHckAY");


export async function formatBehavior(behavior: any): Promise<[]> {
    functions.logger.log('Behavior to format:', behavior);
    const behaviorText = behavior?.description;
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
                        overall_score: {
                            type: FunctionDeclarationSchemaType.NUMBER,
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

    1. Provide a concise title that summarizes the behavior.
    
    2. Generate a list of personality traits in schema associated with this behavior. For each trait:
       a) Assign a score between -5 and 5, where:
          - Negative scores (-5 to -1) indicate negative aspects - Only give the full score amount when the action affects another person.
          - Zero (0) indicates a neutral aspect
          - Positive scores (1 to 5) indicate positive aspects - Only give the full score amount when the action affects another person.
       b) Provide a brief explanation for the assigned score.
    3. If the description contains any mentions of specific person by name, provide them as a string array.
    4. For any score less than 5, provide a suggestion for how to improve the behavior.
    5. Sometimes the behavior can be suggestive of a personality disorder. For this give a score of up to 5.
    `;
    let result = await model.generateContent(prompt)
    functions.logger.log(result.response.text());
    return JSON.parse(result.response.text());
}