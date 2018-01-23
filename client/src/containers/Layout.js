import LayoutComponent from '../components/Layout';
import { connect } from 'react-redux';

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
export default connect()(LayoutComponent);

