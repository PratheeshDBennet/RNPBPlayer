// MapView.js
import PropTypes from 'prop-types';
import React from 'react';
import { requireNativeComponent } from 'react-native';
class PBPlayerView extends React.Component {
    render() {
        return <NativePlayerView/>;
      }
}

const NativePlayerView = requireNativeComponent('RCTPBPlayerViewManager')
module.exports = PBPlayerView;