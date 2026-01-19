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
  const [multipleDates, setMultipleDates] = useState<string>('');
  const [dateRange, setDateRange] = useState<string>('');

  const handleSingleChange = (e: CustomEvent<{ value: string | null }>) => {
    const value = e.detail?.value;
    console.log('[React] Single date changed:', value);
    setSelectedDate(value);
  };

  const handleMultipleChange = (e: CustomEvent<{ value: string | null }>) => {
    const value = e.detail?.value;
    console.log('[React] Multiple dates changed:', value);
    setMultipleDates(value || '');
  };

  const handleRangeChange = (e: CustomEvent<{ value: string | null }>) => {
    const value = e.detail?.value;
    console.log('[React] Date range changed:', value);
    setDateRange(value || '');
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Calendar & Date Picker</h1>

          {/* Basic Single Selection */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Single Selection</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  mode="single"
                  value={selectedDate || undefined}
                  onChange={handleSingleChange}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
            <p className="text-sm text-gray-500 mt-2">
              Selected: {selectedDate || 'None'}
            </p>
          </div>

          {/* Multiple Selection */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multiple Selection</h2>
            <p className="text-sm text-gray-500 mb-3">
              Click multiple dates to select them
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  mode="multiple"
                  value={multipleDates}
                  onChange={handleMultipleChange}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
            <p className="text-sm text-gray-500 mt-2">
              Selected: {multipleDates || 'None'}
            </p>
          </div>

          {/* Range Selection */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Range Selection</h2>
            <p className="text-sm text-gray-500 mb-3">
              Select a start and end date for a range
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  mode="range"
                  value={dateRange}
                  onChange={handleRangeChange}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
            <p className="text-sm text-gray-500 mt-2">
              Range: {dateRange || 'None'}
            </p>
          </div>

          {/* Dropdown Months */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Dropdown Months</h2>
            <p className="text-sm text-gray-500 mb-3">
              Month selector as a dropdown
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  captionLayout="dropdown-months"
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Dropdown Years */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Dropdown Years</h2>
            <p className="text-sm text-gray-500 mb-3">
              Year selector as a dropdown
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  captionLayout="dropdown-years"
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Full Dropdown */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Full Dropdown (Month & Year)</h2>
            <p className="text-sm text-gray-500 mb-3">
              Both month and year as dropdowns
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  captionLayout="dropdown"
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Hide Navigation */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Hide Navigation</h2>
            <p className="text-sm text-gray-500 mb-3">
              Calendar without prev/next month arrows
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  hideNavigation
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Show Week Numbers */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Show Week Numbers</h2>
            <p className="text-sm text-gray-500 mb-3">
              Display week number column on the left
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  showWeekNumbers
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Fixed Weeks */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Fixed Weeks</h2>
            <p className="text-sm text-gray-500 mb-3">
              Always show 6 weeks for consistent height
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  fixedWeeks
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Hide Outside Days */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Hide Outside Days</h2>
            <p className="text-sm text-gray-500 mb-3">
              Hide days from adjacent months
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  showOutsideDays={false}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Hide Weekday Names */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Hide Weekday Names</h2>
            <p className="text-sm text-gray-500 mb-3">
              Hide the Mon, Tue, Wed... headers
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  hideWeekdayNames
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Multiple Months */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multiple Months</h2>
            <p className="text-sm text-gray-500 mb-3">
              Display two months side by side
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  numberOfMonths={2}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Range with Multiple Months */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Range with Multiple Months</h2>
            <p className="text-sm text-gray-500 mb-3">
              Perfect for selecting date ranges like hotel bookings
            </p>
            <FlutterShadcnCard>
              <FlutterShadcnCardContent className="p-4">
                <FlutterShadcnCalendar
                  mode="range"
                  numberOfMonths={2}
                />
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          {/* Date Picker */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Date Picker</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">Select a date</label>
                <FlutterShadcnDatePicker
                  placeholder="Pick a date"
                  onChange={(e: CustomEvent<{ value: string }>) => console.log('Date selected:', e.detail?.value)}
                />
              </div>
            </div>
          </div>

          {/* Form Example */}
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
