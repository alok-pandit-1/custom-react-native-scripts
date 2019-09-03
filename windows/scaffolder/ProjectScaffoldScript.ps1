Write-Host "Project Initialization Started" -ForegroundColor Green;
$ProjectName = $args[0]; 
if($args[1]) {
    Write-Host "Creating a react native project with a specific version"  -ForegroundColor Green;
    react-native init $args[0] --version $args[1];
}
ElseIf($args[0]){
    Write-Host "Creating a react native project named: " $ProjectName  -ForegroundColor Green;
    react-native init $args[0];
}
else {
    Throw "Not Creating a react native project since no default arguments were specified";
}
Write-Progress -Activity "Adding Plugins" -Status "Started"; 
Write-Host "Adding Plugins" -ForegroundColor Green;
Set-Location ./$ProjectName;
yarn add react-navigation react-native-vector-icons react-native-gesture-handler redux react-redux react-native-extended-stylesheet axios realm moment redux-saga -E;
yarn add -D redux-devtools -E;

Write-Host "Adding Plugins" -ForegroundColor Green;
Write-Progress -Activity "Added Plugins" -Completed;
Write-Host "Adding Content" -ForegroundColor Green;

$ProjectNameSpace = 'package com.' + $ProjectName.ToLower() + ';';
Set-Content -Path android/app/src/main/java/com/$ProjectName/MainActivity.java -Value $ProjectNameSpace;
Add-Content -Path android/app/src/main/java/com/$ProjectName/MainActivity.java -Value "
import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.ReactRootView;
import com.swmansion.gesturehandler.react.RNGestureHandlerEnabledRootView;

public class MainActivity extends ReactActivity {

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return `"$ProjectName`";
    }

    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
      return new ReactActivityDelegate(this, getMainComponentName()) {
        @Override
        protected ReactRootView createRootView() {
         return new RNGestureHandlerEnabledRootView(MainActivity.this);
        }
      };
    }
    
}";

mkdir src;
mkdir src/redux, src/routes, src/assets, src/components, src/utils, src/utils/constants, src/utils/payloads, src/utils/services, src/redux/sagas, src/redux/reducers, src/redux/middleware, src/redux/action-creators, src/redux/middleware/validator;
New-Item src/redux/sagas/index.js;
New-Item src/redux/reducers/index.js;
New-Item src/utils/constants/index.js;
New-Item src/routes/index.js;
New-Item src/redux/index.js;
New-Item src/utils/payloads/index.js;
New-Item src/utils/services/APICallingService.js;
New-Item src/utils/services/NavigationService.js;
New-Item src/utils/validator.js;
New-Item src/redux/middleware/validator/index.js;
New-Item src/redux/middleware/validator/validationHelpers.js;
New-Item src/redux/middleware/logger.js;
Set-Content -Path src/redux/middleware/logger.js -Value "const logger = store => next => action => {

    console.group(action.type);

    console.info('dispatching', action);

    let result = next(action);

    console.log('next state', store.getState());

    console.groupEnd();

    return result;
    
  }
  
  export default logger;";
Set-Content -Path src/redux/index.js -Value "import { createStore, compose, applyMiddleware } from 'redux';
import RootReducer from './reducers';
import logger from './middleware/logger';
import validation from './middleware/validator';
import createSagaMiddleware from 'redux-saga';
import rootSaga from './sagas';

const loggerMiddleware = applyMiddleware(logger);
const validatorMiddleware = applyMiddleware(validation);
const sagaMiddleware = createSagaMiddleware();

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const storeEnhancingMiddleware = composeEnhancers(
  loggerMiddleware,
  validatorMiddleware,
  applyMiddleware(sagaMiddleware)
);

const store = createStore(RootReducer, undefined, storeEnhancingMiddleware);

sagaMiddleware.run(rootSaga);

export default store;";
Set-Content -Path src/utils/validator.js -Value "const validator =  {
 
    validateNotEmpty: (str) => {
        let regex = new RegExp('.{1,}', 'g');
        return regex.test(str);
    },
    
    validateUsername: (str) => {
        let regex = new RegExp('.{1,}', 'g');
        return regex.test(str);
    },

    validatePassword: (str) => {
        let regex = new RegExp('^[a-zA-Z0-9]{1}.{3,}', 'g');
        return regex.test(str);
    },

    validatePhone: (str) => {
        let regex = new RegExp('[0-9]{8,12}', 'g');
        return regex.test(str);
    },

    validateEmail: (str) => {
        let regex = new RegExp(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/);
        return regex.test(str);
    },
    
    validateNo :(str) => {
        let regex = new RegExp('^[a-zA-Z0-9]{1}.{5,}', 'g');
        return regex.test(str);
    },

    validateSearchField: (str) => {
        let regex = new RegExp('[^\?&\*#@ *]', 'g');
        return regex.test(str);
    }
    
};

export default validator;";
Set-Content -Path src/utils/services/NavigationService.js -Value "import { StackActions, NavigationActions, DrawerActions } from 'react-navigation';

let navigator;

setTopLevelNavigator = (navigatorRef) => {

  navigator = navigatorRef;

}

replace = (routeName, params) => {

  navigator.dispatch(

    StackActions.replace({
      routeName,
      params
    })

  );

}

navigate = (routeName, params) => {

  navigator.dispatch(

    NavigationActions.navigate({
      routeName,
      params
    })

  );

}

pop = (params) => {

  navigator.dispatch(

    StackActions.pop({
      params
    })

  );

}

toggleDrawer = () => {

  navigator.dispatch(DrawerActions.toggleDrawer());

}

export default { replace, navigate, pop, toggleDrawer, setTopLevelNavigator };";

Set-Content -Path src/utils/services/APICallingService.js -Value "import axios from 'axios';

let APICallingService = {

    sendRequestForPost: async (url, payload, CB, saga) => {

        try {

            var params = payload;

            var formData = new FormData();

            for (var k in params) {
                formData.append(k, params[k]);
            }
    
            let options = {
                method: 'POST',
                url: url,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                data: formData

            };

            return axios(options).then(response => {

                let responseOK = response && response.status == 200;

                console.log(JSON.stringify(response));

                if (responseOK) {

                    return response.data;

                }

                return {
                    status: 'Failed',
                    error: response.data
                }

            })

        } catch (e) {

            return {
                status: 'Failed',
                error: e
            }

        }

    },

    sendRequestForGet: (url, CB) => {

        try {

            axios.get(url)

                .then(response => {

                    let responseOK = response && response.status === 200;

                    if (responseOK) {

                        return response.data;
                    }

                    return {

                        status: 'Failed',
                        error: response.data
                    }

                })


        } catch (e) {

            return {

                status: 'Failed',
                error: e
            }

        }

    }

};

export default APICallingService;";
Write-Host "Done adding content. Visual Studio code will open now." -ForegroundColor Green;
Start-Sleep 1;
code .;
Start-Sleep 1;
exit;
exit;