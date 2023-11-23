<script setup>
import {ref} from 'vue';

const props = defineProps(['items']);
const emit  = defineEmits(['selection']);

const selectedItemId = ref(0);

function select(id) {
    selectedItemId.value = id;
    emit('selection', id);
}
</script>

<template>
    <div>
        <p>Recorded tracks:</p>
        <ul>
            <li :class = "{selected: item.id == selectedItemId}" 
                @click="select(item.id)" 
                v-for="item in items"
            >{{item.start_time}}</li>
        </ul>
    </div>
</template>

<style>
    li {
        cursor: pointer;
    }

    li.selected {
        background-color: lightblue;
    }
</style>