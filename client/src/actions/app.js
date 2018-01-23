export const SIGNED_IN = "SIGNED_IN";

export function signedIn(signedIn){
	return {
		type: SIGNED_IN,
		payload: signedIn
	};	
};