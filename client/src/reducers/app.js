import { 
	SELECTED_MENU_ITEM
} from '../actions/app';

const INITIAL_STATE = {
	selectedMenuItem: 'browse',
};

export default function(state=INITIAL_STATE, action){
	switch(action.type){
		case SELECTED_MENU_ITEM:
			return {
				...state,
				stream: action.payload
			};
			break;
		default:
			return state;
			break;
	}
};
