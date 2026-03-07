<template>
  <div class="flex flex-col items-center">
    <button 
      @click="toggle" 
      class="text-gray-400 hover:text-gray-600 focus:outline-none p-1"
    >
      <ChevronUp :size="16" />
    </button>
    
    <span 
      class="font-bold text-xs py-1 min-w-[60px] text-center select-none uppercase tracking-wide"
      :class="modelValue === 0 ? 'text-emerald-600' : 'text-red-500'"
    >
      {{ modelValue === 0 ? 'BON' : 'PAS BON' }}
    </span>

    <button 
      @click="toggle" 
      class="text-gray-400 hover:text-gray-600 focus:outline-none p-1"
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

const toggle = () => {
  // Toggle between 0 (BON) and 1 (PAS BON)
  emit('update:modelValue', props.modelValue === 0 ? 1 : 0)
}
</script>
