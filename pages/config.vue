<template>
  <div class="config-page sleek-bg">
    <div class="config-card">
      <h1>Calendar & Quote Configuration</h1>
      <form @submit.prevent="saveConfig">
        <h2 class="section-header">Calendars</h2>
        <div v-for="(calendar, idx) in calendars" :key="idx" class="calendar-row">
          <input
            type="text"
            v-model="calendar.label"
            placeholder="Label"
            class="calendar-label-input outlined"
          />
          <label class="color-label">
            <span>Color:</span>
            <input
              type="color"
              v-model="calendar.color"
              class="calendar-color-input"
              @input="onColorInput(idx, $event.target.value)"
            />
            <input
              type="text"
              v-model="calendar.color"
              class="color-hex-input outlined"
              maxlength="7"
              pattern="#?[0-9A-Fa-f]{0,6}"
              @input="onHexInput(idx, $event.target.value)"
              placeholder="#1976d2"
              style="width:90px; margin-left:0.3rem;"
            />
          </label>
          <input
            type="text"
            v-model="calendar.url"
            placeholder="Google Calendar URL"
            class="calendar-url-input outlined"
          />
          <button type="button" class="icon-btn" @click="removeCalendar(idx)" aria-label="Remove calendar">
            <span aria-hidden="true">✕</span>
          </button>
        </div>
        <button type="button" class="add-btn" @click="addCalendar">+ Add Calendar</button>
        <h2 class="section-header">Quote File</h2>
        <div class="quote-url-row full-width-row">
          <input
            type="text"
            v-model="quoteUrl"
            placeholder="Quote file URL"
            class="quote-url-input outlined full-width"
          />
        </div>
        <button type="submit" class="save-btn">Save Configuration</button>
      </form>
      <div v-if="feedback" class="feedback">{{ feedback }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Calendar {
  label: string
  color: string
  url: string
}

const calendars = ref<Calendar[]>([])
const quoteUrl = ref('')
const feedback = ref('')

const LOCALSTORAGE_KEY = 'familyCalendarConfig'

function loadConfig() {
  try {
    const raw = localStorage.getItem(LOCALSTORAGE_KEY)
    if (raw) {
      const parsed = JSON.parse(raw)
      calendars.value = Array.isArray(parsed.calendars)
        ? parsed.calendars.map((c: any) => ({
            label: typeof c.label === 'string' ? c.label : '',
            color: typeof c.color === 'string' ? c.color : '#1976d2',
            url: typeof c.url === 'string' ? c.url : ''
          }))
        : []
      quoteUrl.value = typeof parsed.quoteUrl === 'string' ? parsed.quoteUrl : ''
    }
  } catch (e) {
    feedback.value = 'Failed to load config.'
  }
}

function saveConfig() {
  // Validation
  if (calendars.value.some(c => !c.label.trim() || !c.color.trim() || !c.url.trim())) {
    feedback.value = 'All calendar fields (label, color, URL) are required.'
    return
  }
  if (!quoteUrl.value.trim()) {
    feedback.value = 'Quote file URL cannot be empty.'
    return
  }
  try {
    localStorage.setItem(
      LOCALSTORAGE_KEY,
      JSON.stringify({ calendars: calendars.value, quoteUrl: quoteUrl.value })
    )
    feedback.value = 'Configuration saved!'
  } catch (e) {
    feedback.value = 'Failed to save config.'
  }
}

function addCalendar() {
  calendars.value.push({ label: '', color: '#1976d2', url: '' })
}

function removeCalendar(idx: number) {
  calendars.value.splice(idx, 1)
}

function onColorInput(idx: number, value: string) {
  // Ensure hex format
  if (!/^#([0-9A-Fa-f]{6})$/.test(value)) return
  calendars.value[idx].color = value
}

function onHexInput(idx: number, value: string) {
  // Accept #RRGGBB or RRGGBB
  let hex = value.startsWith('#') ? value : `#${value}`
  if (/^#([0-9A-Fa-f]{6})$/.test(hex)) {
    calendars.value[idx].color = hex
  }
}

onMounted(loadConfig)
</script>

<style scoped>
.sleek-bg {
  min-height: 100vh;
  background: linear-gradient(135deg, #e3f0ff 0%, #f8fafd 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}
.config-card {
  width: 100%;
  max-width: 640px;
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 6px 32px 0 rgba(60, 80, 120, 0.10), 0 1.5px 6px 0 rgba(60, 80, 120, 0.08);
  padding: 2.5rem 2rem 2rem 2rem;
  margin: 2rem 0;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
h1 {
  font-size: 1.7rem;
  font-weight: 700;
  color: #1a237e;
  margin-bottom: 1.2rem;
  text-align: center;
}
form {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}
.calendar-row {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  margin-bottom: 0.2rem;
}
.calendar-label-input,
.calendar-url-input,
.quote-url-input {
  font-size: 1rem;
  padding: 0.6rem 0.9rem;
  border-radius: 7px;
  outline: none;
  transition: border 0.2s, box-shadow 0.2s;
  background: #f7fafd;
  color: #1a237e;
}
.outlined {
  border: 2px solid #b0bec5;
  box-shadow: 0 1px 2px 0 rgba(60, 80, 120, 0.04);
}
.outlined:focus {
  border: 2px solid #1976d2;
  background: #fff;
}
.calendar-label-input {
  width: 110px;
}
  .calendar-color-input {
    width: 38px;
    height: 38px;
    border: none;
    background: none;
    padding: 0;
    cursor: pointer;
    margin-right: 0;
  }
  .color-hex-input {
    width: 90px;
    font-size: 0.98rem;
    margin-left: 0.3rem;
    padding: 0.5rem 0.7rem;
    border-radius: 7px;
    border: 2px solid #b0bec5;
    background: #f7fafd;
    color: #1a237e;
    outline: none;
    transition: border 0.2s, box-shadow 0.2s;
  }
  .color-hex-input:focus {
    border: 2px solid #1976d2;
    background: #fff;
  }
.calendar-url-input {
  flex: 1;
}
.icon-btn {
  background: none;
  border: none;
  color: #b71c1c;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0 0.5rem;
  border-radius: 50%;
  transition: background 0.15s;
}
.icon-btn:hover {
  background: #fbe9e7;
}
.add-btn {
  align-self: flex-start;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 7px;
  padding: 0.5rem 1.1rem;
  font-size: 1rem;
  font-weight: 500;
  margin-top: 0.2rem;
  margin-bottom: 0.5rem;
  cursor: pointer;
  transition: background 0.18s;
}
.add-btn:hover {
  background: #1565c0;
}
.quote-url-row {
  margin: 1.2rem 0 0.2rem 0;
}
.full-width-row {
  display: flex;
}
.quote-url-input.full-width {
  width: 100%;
  flex: 1 1 0%;
  box-sizing: border-box;
  display: block;
}
.save-btn {
  background: linear-gradient(90deg, #1976d2 60%, #42a5f5 100%);
  color: #fff;
  border: none;
  border-radius: 7px;
  padding: 0.7rem 1.2rem;
  font-size: 1.1rem;
  font-weight: 600;
  margin-top: 0.7rem;
  cursor: pointer;
  box-shadow: 0 2px 8px 0 rgba(25, 118, 210, 0.08);
  transition: background 0.18s;
}
.save-btn:hover {
  background: linear-gradient(90deg, #1565c0 60%, #1976d2 100%);
}
.feedback {
  margin-top: 1.2rem;
  color: #2e7d32;
  text-align: center;
  font-weight: 500;
  font-size: 1.08rem;
}
  .section-header {
    font-size: 1.13rem;
    font-weight: 600;
    color: #1976d2;
    margin: 1.2rem 0 0.5rem 0;
    letter-spacing: 0.01em;
  }
  .color-label {
    display: flex;
    align-items: center;
    gap: 0.3rem;
    font-size: 0.98rem;
    color: #374151;
    font-weight: 500;
  }
</style>
