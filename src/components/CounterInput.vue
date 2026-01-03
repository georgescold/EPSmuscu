<template>
  <div class="flex flex-col items-center">
    <button 
      @click="increment" 
      class="text-gray-400 hover:text-emerald-600 focus:outline-none p-1"
    >
      <ChevronUp :size="16" />
    </button>
    
    <span 
      class="font-bold font-mono text-sm py-1 min-w-[30px] text-center select-none"
      :class="modelValue === 0 ? 'text-emerald-600' : 'text-amber-600'"
    >
      {{ modelValue === 0 ? 'Ok' : modelValue }}
    </span>

    <button 
      @click="decrement" 
      class="text-gray-400 hover:text-emerald-600 focus:outline-none p-1"
    >
      <ChevronDown :size="16" />
    </button>
  </div>
</template>

<script setup>
import { ChevronUp, ChevronDown } from 'lucide-vue-next'

const props = defineProps({
  modelValue: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['update:modelValue'])

const increment = () => {
  emit('update:modelValue', props.modelValue + 1)
}

const decrement = () => {
  if (props.modelValue > 0) {
    emit('update:modelValue', props.modelValue - 1)
  }
}
</script>
