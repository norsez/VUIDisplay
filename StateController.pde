
interface StateActionCallback {
  void callbackWith(StateSequenceController sc, State s, PGraphics g);
}

class State {
  int stateId;
  float durationInFrames;

  State(int id, float durationInFrames) {
    this.stateId = id;
    this.durationInFrames = durationInFrames;
  }

  String toString() {
    return "state id: "+ this.stateId;
  }
}

class StateSequenceController {
  List<State> states;
  int stateIndex = 0;
  float currentFrame = 0;
  List<StateActionCallback> listeners;

  StateSequenceController () {
    states = new ArrayList();
    listeners = new ArrayList();
  }

  void add(State s) {
    states.add(s);
  }

  float getCurrentDx(){
    State state = getCurrentState();
    return state.durationInFrames;
  }
  
  State getCurrentState() {
    return this.states.get(stateIndex);
  }

  void tick() { 
    //pdebug("state controller tick. currentFrame: " + currentFrame + ", current dx: " + this.getCurrentDx());
    currentFrame++;
    
    if (currentFrame >= this.getCurrentDx()) {
      pdebug("state: " + stateIndex);
      for(StateActionCallback s: listeners) {
        s.callbackWith(this, getCurrentState(), g);
      }

      currentFrame = 0;
      stateIndex = (stateIndex + 1) % this.states.size();
    }

    //pdebug("state: " + stateIndex +", currentFrame: " + currentFrame);
  }
}
