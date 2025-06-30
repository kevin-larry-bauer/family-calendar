import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import ICAL from 'ical.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

interface CalendarConfig {
  name: string
  url: string
  color: string
}

interface CalendarEvent {
  id: string
  title: string
  start: string
  end: string
  description?: string
  location?: string
  calendar: string
  color: string
  isRecurring?: boolean
}

export default defineEventHandler(async (event) => {
  try {
    // Read calendar configuration
    const configPath = path.join(process.cwd(), 'calendar-locations.json')
    
    if (!fs.existsSync(configPath)) {
      throw createError({
        statusCode: 404,
        statusMessage: 'Calendar configuration file not found. Please create calendar-locations.json'
      })
    }

    const configData = JSON.parse(fs.readFileSync(configPath, 'utf-8'))
    const calendars: CalendarConfig[] = configData.calendars

    const allEvents: CalendarEvent[] = []

    // Fetch and parse each calendar
    for (const calendar of calendars) {
      try {
        const response = await fetch(calendar.url)
        if (!response.ok) {
          console.warn(`Failed to fetch calendar ${calendar.name}: ${response.status} ${response.statusText}`)
          continue
        }

        const icalData = await response.text()
        
        const jcalData = ICAL.parse(icalData)
        const comp = new ICAL.Component(jcalData)
        const vevents = comp.getAllSubcomponents('vevent')

        // Set up date range for recurring event expansion
        const now = new Date()
        const pastLimit = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
        const futureLimit = new Date(now.getTime() + 90 * 24 * 60 * 60 * 1000)

        for (const vevent of vevents) {
          const event = new ICAL.Event(vevent)
          
          // Check if this is a recurring event
          if (event.isRecurring()) {
            
            // Create an iterator for recurring events
            const iterator = event.iterator()
            let next
            
            // Expand recurring events within our date range
            while ((next = iterator.next())) {
              const startDate = next.toJSDate()
              
              // Stop if we're beyond our future limit
              if (startDate > futureLimit) break
              
              // Include if within our date range
              if (startDate >= pastLimit && startDate <= futureLimit) {
                // Calculate end date for this occurrence
                const duration = event.endDate.subtractDate(event.startDate)
                const endDate = next.clone()
                endDate.addDuration(duration)
                
                const calendarEvent = {
                  id: `${calendar.name}-${event.uid}-${startDate.getTime()}`, // Unique ID for each occurrence
                  title: event.summary,
                  start: startDate.toISOString(),
                  end: endDate.toJSDate().toISOString(),
                  description: event.description || '',
                  location: event.location || '',
                  calendar: calendar.name,
                  color: calendar.color,
                  isRecurring: true
                }
                allEvents.push(calendarEvent)
              }
              
              // Safety check to prevent infinite loops
              if (allEvents.length > 10000) {
                console.warn(`Too many events generated for ${calendar.name}, stopping expansion`)
                break
              }
            }
          } else {
            // Handle single (non-recurring) events
            const startDate = event.startDate.toJSDate()
            
            if (startDate >= pastLimit && startDate <= futureLimit) {
              const calendarEvent = {
                id: `${calendar.name}-${event.uid}`,
                title: event.summary,
                start: event.startDate.toJSDate().toISOString(),
                end: event.endDate.toJSDate().toISOString(),
                description: event.description || '',
                location: event.location || '',
                calendar: calendar.name,
                color: calendar.color,
                isRecurring: false
              }
              allEvents.push(calendarEvent)
            }
          }
        }
      } catch (error) {
        console.error(`Error processing calendar ${calendar.name}:`, error)
      }
    }

    // Sort events by start date
    allEvents.sort((a, b) => new Date(a.start).getTime() - new Date(b.start).getTime())
    
    const recurringCount = allEvents.filter(e => e.isRecurring).length
    const singleCount = allEvents.filter(e => !e.isRecurring).length
    
    return {
      events: allEvents,
      lastUpdated: new Date().toISOString(),
      calendarsProcessed: calendars.length,
      stats: {
        total: allEvents.length,
        single: singleCount,
        recurring: recurringCount
      }
    }
  } catch (error) {
    console.error('Error fetching calendar events:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to fetch calendar events'
    })
  }
})
