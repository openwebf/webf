import * as React from 'react';
import { cn } from '../../lib/utils';
import { Button } from './button';

const WEEKDAYS = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

function startOfMonth(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function isSameDay(left: Date, right: Date) {
  return (
    left.getFullYear() === right.getFullYear() &&
    left.getMonth() === right.getMonth() &&
    left.getDate() === right.getDate()
  );
}

function getMonthMatrix(month: Date) {
  const firstDay = startOfMonth(month);
  const offset = firstDay.getDay();
  const firstCell = new Date(firstDay);
  firstCell.setDate(firstDay.getDate() - offset);

  return Array.from({ length: 6 }, (_, weekIndex) =>
    Array.from({ length: 7 }, (_, dayIndex) => {
      const date = new Date(firstCell);
      date.setDate(firstCell.getDate() + weekIndex * 7 + dayIndex);
      return date;
    }),
  );
}

function getWeekNumber(date: Date) {
  const start = new Date(date.getFullYear(), 0, 1);
  const diff = date.getTime() - start.getTime();
  return Math.ceil((diff / 86400000 + start.getDay() + 1) / 7);
}

export interface CalendarProps extends React.HTMLAttributes<HTMLDivElement> {
  mode?: 'single';
  selected?: Date;
  onSelect?: (date: Date) => void;
  captionLayout?: 'label' | 'dropdown';
  showOutsideDays?: boolean;
  showWeekNumber?: boolean;
  fromYear?: number;
  toYear?: number;
}

export function Calendar({
  selected,
  onSelect,
  className,
  captionLayout = 'label',
  showOutsideDays = true,
  showWeekNumber = false,
  fromYear,
  toYear,
  ...props
}: CalendarProps) {
  const today = React.useMemo(() => new Date(), []);
  const [displayMonth, setDisplayMonth] = React.useState<Date>(
    selected ? startOfMonth(selected) : startOfMonth(today),
  );

  React.useEffect(() => {
    if (selected) {
      setDisplayMonth(startOfMonth(selected));
    }
  }, [selected]);

  const years = React.useMemo(() => {
    const currentYear = today.getFullYear();
    const startYear = fromYear ?? currentYear - 5;
    const endYear = toYear ?? currentYear + 5;
    return Array.from(
      { length: endYear - startYear + 1 },
      (_, index) => startYear + index,
    );
  }, [fromYear, toYear, today]);

  const weeks = React.useMemo(() => getMonthMatrix(displayMonth), [displayMonth]);

  return (
    <div
      className={cn('w-fit rounded-lg border border-zinc-200 bg-white p-3', className)}
      {...props}
    >
      <div className="mb-3 flex items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon-sm"
            onClick={() =>
              setDisplayMonth(
                new Date(displayMonth.getFullYear(), displayMonth.getMonth() - 1, 1),
              )
            }
          >
            ‹
          </Button>
          {captionLayout === 'dropdown' ? (
            <div className="flex items-center gap-2">
              <select
                className="h-8 rounded-md border border-zinc-200 bg-white px-2 text-sm text-zinc-700"
                value={displayMonth.getMonth()}
                onChange={(event) =>
                  setDisplayMonth(
                    new Date(
                      displayMonth.getFullYear(),
                      Number(event.target.value),
                      1,
                    ),
                  )
                }
              >
                {MONTHS.map((monthLabel, index) => (
                  <option key={monthLabel} value={index}>
                    {monthLabel.slice(0, 3)}
                  </option>
                ))}
              </select>
              <select
                className="h-8 rounded-md border border-zinc-200 bg-white px-2 text-sm text-zinc-700"
                value={displayMonth.getFullYear()}
                onChange={(event) =>
                  setDisplayMonth(
                    new Date(
                      Number(event.target.value),
                      displayMonth.getMonth(),
                      1,
                    ),
                  )
                }
              >
                {years.map((year) => (
                  <option key={year} value={year}>
                    {year}
                  </option>
                ))}
              </select>
            </div>
          ) : (
            <div className="text-sm font-medium text-zinc-950">
              {MONTHS[displayMonth.getMonth()]} {displayMonth.getFullYear()}
            </div>
          )}
        </div>
        <Button
          variant="ghost"
          size="icon-sm"
          onClick={() =>
            setDisplayMonth(
              new Date(displayMonth.getFullYear(), displayMonth.getMonth() + 1, 1),
            )
          }
        >
          ›
        </Button>
      </div>

      <div
        className={cn(
          'grid gap-1 text-center text-xs text-zinc-500',
          showWeekNumber ? 'grid-cols-[28px_repeat(7,1fr)]' : 'grid-cols-7',
        )}
      >
        {showWeekNumber ? <div className="h-8" /> : null}
        {WEEKDAYS.map((weekday) => (
          <div
            key={weekday}
            className="flex h-8 items-center justify-center font-medium"
          >
            {weekday}
          </div>
        ))}

        {weeks.map((week) => (
          <React.Fragment key={week[0].toISOString()}>
            {showWeekNumber ? (
              <div className="flex h-9 items-center justify-center text-[11px] text-zinc-400">
                {getWeekNumber(week[0])}
              </div>
            ) : null}
            {week.map((day) => {
              const outside = day.getMonth() !== displayMonth.getMonth();
              const active = selected ? isSameDay(day, selected) : false;
              const isToday = isSameDay(day, today);

              if (outside && !showOutsideDays) {
                return <div key={day.toISOString()} className="h-9 w-9" />;
              }

              return (
                <button
                  key={day.toISOString()}
                  type="button"
                  className={cn(
                    'flex h-9 w-9 items-center justify-center rounded-md text-sm transition-colors',
                    active
                      ? 'bg-zinc-900 text-white'
                      : 'text-zinc-800 hover:bg-zinc-100',
                    outside && 'text-zinc-400',
                    isToday && !active && 'border border-zinc-200',
                  )}
                  onClick={() => onSelect?.(day)}
                >
                  {day.getDate()}
                </button>
              );
            })}
          </React.Fragment>
        ))}
      </div>
    </div>
  );
}
