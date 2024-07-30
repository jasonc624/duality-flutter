import { functions } from "firebase-functions";

export async function formatBehavior(behavior: any) {
    const behaviorText = behavior.data();
    functions.logger.log(behaviorText);
}