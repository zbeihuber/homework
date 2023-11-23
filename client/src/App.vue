<script setup>
import Tracker from './components/Tracker.vue'
import { ref, provide } from 'vue';
import { io } from 'socket.io-client'

const SERVER_ADDRESS = 'localhost:3000';
const BASE_URL = `http://${SERVER_ADDRESS}`;
const BOAT_ID  = 1;

const history = ref([])
const position = ref({
  latitude: 47.5,
  longitude: 19,
  heading: 0
})
const recording = ref(false)
const track = ref([])

async function refreshHistory () {
  const response = await fetch(BASE_URL + '/boats/' + BOAT_ID + '/routes');
  history.value = await response.json();
}
refreshHistory();

provide('getRoute', async (routeId) => {
  const response = await fetch(BASE_URL + '/routes/' + routeId);
  return await response.json();
})

const socket = io(`ws://${SERVER_ADDRESS}`);

socket.on('connect', () => {
  socket.emit('watch', {boat: BOAT_ID});
 
});

socket.on('state', state => {
  position.value = state.position;
  recording.value = state.isRecording;
  track.value = state.route;
});

socket.on('position', pos => {
  position.value = pos
  if (recording.value == true) {
    track.value.push(pos);
  }
});

function toggleRecording () {
  if (recording.value) {
    socket.emit('stop recording', {boat: BOAT_ID})
  } else {
    socket.emit('start recording', {boat: BOAT_ID})
  }
}

socket.on('recording stopped', () => {
  track.value = [];
  recording.value = false;
  refreshHistory();
})

socket.on('recording started', () => {
  recording.value = true;
})

</script>
 
<template>
    <Tracker 
      :history="history"
      :position="position" 
      :recording="recording"
      :track="track"
      @toggle-recording="toggleRecording()"></Tracker>
</template>

<style scoped>


</style>
