import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnCalendar,
  FlutterShadcnDatePicker,
  FlutterShadcnCard,
  FlutterShadcnCardHeader,
  FlutterShadcnCardTitle,
  FlutterShadcnCardContent,
} from '@openwebf/react-shadcn-ui';

export const ShadcnCalendarPage: React.FC = () => {
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Calendar & Date Picker</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Calendar</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  value={selectedDate || undefined}
                  onChange={(e: any) => setSelectedDate(e.detail?.value)}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
            <p className="text-sm text-gray-500 mt-2">
              Selected: {selectedDate || 'None'}
            </p>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Date Picker</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Select a date</label>
                <FlutterShadcnDatePicker
                  placeholder="Pick a date"
                  onChange={(e: any) => console.log('Date selected:', e.detail?.value)}
                />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Date Picker with Label</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Book an Appointment</FlutterShadcnCardTitle>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Appointment Date</label>
                    <FlutterShadcnDatePicker placeholder="Select date" />
                  </div>
                  <p className="text-sm text-gray-500">
                    Please select a date for your appointment. Weekends are not available.
                  </p>
                </div>
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Date Range Example</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Travel Dates</FlutterShadcnCardTitle>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Check-in</label>
                    <FlutterShadcnDatePicker placeholder="Select check-in date" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Check-out</label>
                    <FlutterShadcnDatePicker placeholder="Select check-out date" />
                  </div>
                </div>
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Form with Date</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <FlutterShadcnCardTitle>Event Registration</FlutterShadcnCardTitle>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Event Name</label>
                    <input
                      type="text"
                      className="w-full px-3 py-2 border rounded-md"
                      placeholder="Enter event name"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Event Date</label>
                    <FlutterShadcnDatePicker placeholder="Select event date" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Registration Deadline</label>
                    <FlutterShadcnDatePicker placeholder="Select deadline" />
                  </div>
                </div>
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
