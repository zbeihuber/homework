<script setup>
import { ref, computed, inject } from 'vue';
import Map from './Map.vue'
import TrackList from './TrackList.vue'

const props = defineProps(['history', 'position', 'recording', 'track']);
const emit = defineEmits(['toggleRecording']);

const buttonTitle = computed(() => {
  if (props.recording) {
    return 'Stop recording';
  } else {
    return 'Start recording';
  }
});

const highlight = ref([]);

const getRoute = inject('getRoute');

async function setHighlight (routeId) {
    highlight.value = await getRoute(routeId);
}

</script>
 
<template>
    <button @click="$emit('toggleRecording')">{{ buttonTitle }}</button>
    <Map :position="props.position" :track="props.track" :highlight="highlight"></Map>
    <TrackList :items="props.history" @selection=" setHighlight($event)"></TrackList>
</template>

<style scoped>


</style>
