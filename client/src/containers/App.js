import AppComponent from '../components/App';
import { connect } from 'react-redux';
import { 
	signedIn
} from '../actions/app';


const mapDispatchToProps = (dispatch) => {
	return {
		SignedIn: (signedIn) => {
			dispatch(signedIn(signedIn));	
		}
	};
};

function mapStateToProps(state){
	return {
		app: state.app,
	};
}

export default connect(mapStateToProps, mapDispatchToProps)(AppComponent);
//export default connect()(AppComponent);

