export const SELECTED_MENU_ITEM = "SELECTED_MENU_ITEM";

export function selectedMenuItem(item){
	return {
		type: SELECTED_MENU_ITEM,
		payload: item
	};	
};