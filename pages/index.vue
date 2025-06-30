<template>
  <div class="h-screen w-screen bg-gray-900 text-white overflow-hidden">
    <div class="flex h-full">
      <!-- Left Sidebar (25% width) -->
      <div class="w-1/4 bg-gray-800 p-6 flex flex-col">
        <!-- Clock -->
        <div class="mb-8">
          <div class="text-6xl font-light mb-2">{{ currentTime }}</div>
          <div class="text-xl text-gray-300">{{ currentDate }}</div>
        </div>

        <!-- Today's Agenda -->
        <div class="flex-1 overflow-hidden">
          <h2 class="text-2xl font-semibold mb-4 text-blue-400">Today's Agenda</h2>
          
          <!-- Loading State -->
          <div v-if="pending" class="flex items-center justify-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-400"></div>
          </div>

          <!-- Error State -->
          <div v-else-if="error" class="bg-red-900 bg-opacity-50 border border-red-700 rounded-lg p-3 mb-4">
            <p class="text-red-300 text-sm">{{ error.message }}</p>
          </div>

          <!-- Today's Events -->
          <div v-else class="space-y-3 overflow-y-auto max-h-full">
            <div v-if="todayEvents.length === 0" class="text-gray-400 text-center py-8">
              <div class="text-4xl mb-2">✨</div>
              <p>No events today</p>
            </div>
            
            <div 
              v-for="event in todayEvents" 
              :key="event.id"
              class="bg-gray-700 rounded-lg p-3 border-l-4"
              :style="{ borderLeftColor: event.color }"
            >
              <div class="font-medium text-sm mb-1">{{ event.title }}</div>
              <div class="text-xs text-gray-300 mb-1">
                {{ formatTime(event.start) }} - {{ formatTime(event.end) }}
              </div>
              <div v-if="event.location" class="text-xs text-gray-400 flex items-center">
                <span class="mr-1">📍</span>
                {{ event.location }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Main Area (75% width) -->
      <div class="flex-1 p-6">
        <div class="h-full">
          <!-- Header -->
          <div class="mb-6">
            <div class="flex items-center justify-between">
              <h1 class="text-4xl font-light">Bauer Family Calendar - {{ weekRangeText }}</h1>
              <div class="text-right">
                <div v-if="pending" class="flex items-center text-blue-400 text-sm">
                  <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-400 mr-2"></div>
                  Updating...
                </div>
                <div v-else-if="data?.lastUpdated" class="text-gray-400 text-sm">
                  Last updated: {{ formatLastUpdated(data.lastUpdated) }}
                </div>
              </div>
            </div>
          </div>

          <!-- Two-Week Calendar Grid -->
          <div class="grid grid-cols-7 gap-2 h-5/6">
            <!-- Day Headers -->
            <div 
              v-for="day in dayHeaders" 
              :key="day"
              class="text-center text-gray-300 font-medium py-2 text-lg"
            >
              {{ day }}
            </div>

            <!-- Calendar Days -->
            <div 
              v-for="day in calendarDays" 
              :key="day.date"
              class="bg-gray-800 rounded-lg p-3 flex flex-col min-h-48"
              :class="{
                'bg-blue-900 bg-opacity-50': day.isToday,
                'opacity-50': !day.isCurrentMonth
              }"
            >
              <!-- Date Number -->
              <div 
                class="text-right mb-2 font-medium"
                :class="{
                  'text-blue-400': day.isToday,
                  'text-gray-300': day.isCurrentMonth && !day.isToday,
                  'text-gray-500': !day.isCurrentMonth
                }"
              >
                {{ day.dayNumber }}
              </div>

              <!-- Events for this day -->
              <div class="flex-1 space-y-1 overflow-y-auto day-events-container">
                <div 
                  v-for="event in day.events.slice(0, 8)" 
                  :key="event.id"
                  class="text-xs p-1 rounded text-white flex items-start"
                  :style="{ backgroundColor: event.color }"
                  :title="event.title + ' - ' + formatTime(event.start) + ' (' + event.calendar + ')'"
                >
                  <span class="line-clamp-2 leading-tight">
                    <span class="font-medium">{{ formatTime(event.start) }}</span> {{ event.title }}
                  </span>
                </div>
                <div 
                  v-if="day.events.length > 8" 
                  class="text-xs text-gray-400 text-center"
                >
                  +{{ day.events.length - 8 }} more
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

// Fetch events from our API
const { data, pending, error, refresh } = await useFetch('/api/events')

// Current time and date
const currentTime = ref('')
const currentDate = ref('')

// Update time every second
let timeInterval
let refreshInterval
let dailyReloadInterval

onMounted(() => {
  updateTime()
  timeInterval = setInterval(updateTime, 1000)
  
  // Refresh calendar events every 15 minutes (900,000 ms)
  refreshInterval = setInterval(() => {
    console.log('Refreshing calendar events...')
    refresh()
  }, 15 * 60 * 1000)
  
  // Reload the entire page once a day (24 hours = 86,400,000 ms)
  dailyReloadInterval = setInterval(() => {
    console.log('Daily page reload...')
    window.location.reload()
  }, 24 * 60 * 60 * 1000)
})

onUnmounted(() => {
  if (timeInterval) clearInterval(timeInterval)
  if (refreshInterval) clearInterval(refreshInterval)
  if (dailyReloadInterval) clearInterval(dailyReloadInterval)
})

const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  })
  currentDate.value = now.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  })
}

// Day headers for the calendar
const dayHeaders = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

// Get today's events
const todayEvents = computed(() => {
  if (!data.value?.events) return []
  
  const today = new Date()
  const todayStr = today.toDateString()

  return data.value.events
    .filter(event => new Date(event.start).toDateString() === todayStr)
    .sort((a, b) => new Date(a.start) - new Date(b.start))
})

// Generate calendar days for current week and next week
const calendarDays = computed(() => {
  if (!data.value?.events) return []
  
  const today = new Date()
  const startOfWeek = new Date(today)
  startOfWeek.setDate(today.getDate() - today.getDay()) // Start from Sunday
  
  const days = []
  
  // Generate 14 days (2 weeks)
  for (let i = 0; i < 14; i++) {
    const date = new Date(startOfWeek)
    date.setDate(startOfWeek.getDate() + i)
    
    const dayEvents = data.value.events.filter(event => {
      const eventDate = new Date(event.start)
      const isMatch = eventDate.toDateString() === date.toDateString()
      return isMatch
    }).sort((a, b) => new Date(a.start) - new Date(b.start))
    
    days.push({
      date: date.toISOString(),
      dayNumber: date.getDate(),
      isToday: date.toDateString() === today.toDateString(),
      isCurrentMonth: date.getMonth() === today.getMonth(),
      events: dayEvents
    })
  }
  
  return days
})

// Week range text
const weekRangeText = computed(() => {
  if (calendarDays.value.length === 0) return ''
  
  const firstDay = new Date(calendarDays.value[0].date)
  const lastDay = new Date(calendarDays.value[13].date)
  
  const formatOptions = { month: 'long', day: 'numeric' }
  const firstStr = firstDay.toLocaleDateString('en-US', formatOptions)
  const lastStr = lastDay.toLocaleDateString('en-US', formatOptions)
  
  return `${firstStr} - ${lastStr}, ${lastDay.getFullYear()}`
})

// Utility functions
const formatTime = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  })
}

const formatLastUpdated = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  })
}

// Set page meta
useHead({
  title: 'Family Calendar Dashboard',
  meta: [
    { name: 'description', content: 'Fullscreen family calendar dashboard' }
  ]
})
</script>

<style scoped>
/* Custom scrollbar for webkit browsers */
::-webkit-scrollbar {
  width: 4px;
}

::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
}

::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 2px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}

/* Hide scrollbar for day event containers */
.day-events-container {
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* Internet Explorer 10+ */
}

.day-events-container::-webkit-scrollbar {
  display: none; /* Safari and Chrome */
}

/* Line clamp utility for text truncation */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  word-break: break-word;
}
</style>
