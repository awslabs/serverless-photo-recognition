import AppComponent from '../components/App';
import { connect } from 'react-redux';
// import { 
// 	selectedMenuItem
// } from '../actions/app';


// const mapDispatchToProps = (dispatch) => {
// 	return {
// 		selectedMenuItem: (item) => {
// 			dispatch(selectedMenuItem(item));	
// 		}
// 	};
// };

// function mapStateToProps(state){
// 	return {
// 		app: state.app,
// 	};
// }

//export default connect(mapStateToProps, mapDispatchToProps)(AppSignedIn);
export default connect()(AppComponent);

