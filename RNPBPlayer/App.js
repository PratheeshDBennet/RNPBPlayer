import React, { Component } from 'react';
import PropTypes from 'prop-types';
import ReactNative,{ StyleSheet, View, requireNativeComponent, Button, state } from 'react-native';
const PBPlayer = requireNativeComponent('PBPlayer');
import { NativeModules } from 'react-native'
console.log(NativeModules.PBPlayer)
export default class App extends Component {
  constructor(props) {
    super(props)

    // Binding this keyword
    this.state = { isPlaying: false }
    this.handleClick = this.handleClick.bind(this)
    this.handlePlayerEnd = this.handlePlayerEnd.bind(this)
    this.handlePlayerPlay = this.handlePlayerPlay.bind(this)
    this.handlePlayerPause = this.handlePlayerPause.bind(this)
  }
  handleClick() {
    NativeModules.PBPlayer.playPauseAction(
      ReactNative.findNodeHandle(this.mySwiftComponentInstance),
      value => {
        this.setState({
          isPlaying: value
        })
        console.log("Is playing status is" + value)
      })
  }
  handlePlayerEnd(event) {
    console.log("Player end", event.nativeEvent)
    this.setState({
      isPlaying: event.nativeEvent.isPlaying
    })
  }
  handlePlayerPlay(event) {
    console.log("Player end")
  }
  handlePlayerPause(event) {
    console.log("Player pause")
  }
  static defaultProps = {
    url: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
  };
  render() {
    console.log("After", this.props.url)
    return (
      <View style={styles.container}>
        <PBPlayer style={styles.nativeBtn}
         ref={(component) => this.mySwiftComponentInstance = component}
          url={this.props.url}
          onEnd={
            this.handlePlayerEnd
          }
          onPlay={ 
            this.handlePlayerPlay
          } 
          onPause={
            this.handlePlayerPause
          } 
        />
        <Button
          title={this.state.isPlaying ? "Pause" : "Play"}
          onPress={this.handleClick}
        />
      </View>
    );
  }
}
App.propTypes = {
  /**
   * A Boolean value that determines whether the user may use pinch
   * gestures to zoom in and out of the map.
   */
  onEnd: PropTypes.func,
  url: PropTypes.string
};
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'pink',
    alignItems: 'center',
    justifyContent: 'center',
  },
  nativeBtn: {
    height: 200,
    width: 300,
    backgroundColor: 'yellow',
  },
});