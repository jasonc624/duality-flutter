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
    let prompt = `Based on the inputted behavior please provide a title, 
    and traitlist associated with the behavior, 
    for the traitlist the scale is -5 to 5 
    where a negative number is a bad trait and a positive number is a good trait.
    The title should be a short description of the behavior.`;
    let result = await model.generateContent(prompt)
    functions.logger.log(result.response.text());
    return JSON.parse(result.response.text());
}