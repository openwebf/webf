import * as React from 'react';
import { cn } from '../../lib/utils';
import { Button } from './button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './select';

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
  style,
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
  const monthOptions = React.useMemo(
    () =>
      MONTHS.map((monthLabel, index) => ({
        value: String(index),
        label: monthLabel.slice(0, 3),
      })),
    [],
  );
  const dayCellSize = captionLayout === 'dropdown' ? 40 : 36;
  const weekNumberColumnWidth = showWeekNumber ? 32 : 0;
  const columnCount = showWeekNumber ? 8 : 7;
  const gridGap = 4;
  const calendarGridWidth =
    weekNumberColumnWidth + dayCellSize * 7 + gridGap * (columnCount - 1);
  const calendarWidth = calendarGridWidth + 24;
  const monthTriggerWidth = 74;
  const yearTriggerWidth = 90;
  const monthContentWidth = 88;
  const yearContentWidth = 104;

  return (
    <div
      className={cn('rounded-lg border border-zinc-200 bg-white p-3', className)}
      style={{ width: `${calendarWidth}px`, ...style }}
      {...props}
    >
      <div className="mb-3 grid grid-cols-[32px_minmax(0,1fr)_32px] items-center gap-2">
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
          <div className="flex min-w-0 items-center justify-center gap-1.5">
            <Select
              value={String(displayMonth.getMonth())}
              onValueChange={(nextMonth) =>
                setDisplayMonth(
                  new Date(displayMonth.getFullYear(), Number(nextMonth), 1),
                )
              }
            >
              <SelectTrigger
                className="h-8 min-w-0 gap-1 px-2 py-1 text-sm shadow-none"
                style={{ width: `${monthTriggerWidth}px`, minWidth: `${monthTriggerWidth}px` }}
              >
                <SelectValue placeholder={monthOptions[displayMonth.getMonth()].label} />
              </SelectTrigger>
              <SelectContent
                className="min-w-0"
                style={{ width: `${monthContentWidth}px`, minWidth: `${monthContentWidth}px` }}
              >
                {monthOptions.map((month) => (
                  <SelectItem key={month.value} value={month.value}>
                    {month.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select
              value={String(displayMonth.getFullYear())}
              onValueChange={(nextYear) =>
                setDisplayMonth(
                  new Date(Number(nextYear), displayMonth.getMonth(), 1),
                )
              }
            >
              <SelectTrigger
                className="h-8 min-w-0 gap-1 px-2 py-1 text-sm shadow-none"
                style={{ width: `${yearTriggerWidth}px`, minWidth: `${yearTriggerWidth}px` }}
              >
                <SelectValue placeholder={String(displayMonth.getFullYear())} />
              </SelectTrigger>
              <SelectContent
                className="min-w-0"
                style={{ width: `${yearContentWidth}px`, minWidth: `${yearContentWidth}px` }}
              >
                {years.map((year) => (
                  <SelectItem key={year} value={String(year)}>
                    {year}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        ) : (
          <div className="text-center text-sm font-medium text-zinc-950">
            {MONTHS[displayMonth.getMonth()]} {displayMonth.getFullYear()}
          </div>
        )}
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
        className="grid gap-1 text-center text-xs text-zinc-500"
        style={{
          gridTemplateColumns: showWeekNumber
            ? `32px repeat(7, minmax(${dayCellSize}px, 1fr))`
            : `repeat(7, minmax(${dayCellSize}px, 1fr))`,
        }}
      >
        {showWeekNumber ? <div className="h-10" /> : null}
        {WEEKDAYS.map((weekday) => (
          <div
            key={weekday}
            className="flex h-10 items-center justify-center font-medium"
          >
            {weekday}
          </div>
        ))}

        {weeks.map((week) => (
          <React.Fragment key={week[0].toISOString()}>
            {showWeekNumber ? (
              <div className="flex h-10 items-center justify-center text-[11px] text-zinc-400">
                {getWeekNumber(week[0])}
              </div>
            ) : null}
            {week.map((day) => {
              const outside = day.getMonth() !== displayMonth.getMonth();
              const active = selected ? isSameDay(day, selected) : false;
              const isToday = isSameDay(day, today);

              if (outside && !showOutsideDays) {
                return <div key={day.toISOString()} className="h-10" />;
              }

              return (
                <button
                  key={day.toISOString()}
                  type="button"
                  className={cn(
                    'flex h-10 w-full items-center justify-center rounded-md text-sm transition-colors',
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
