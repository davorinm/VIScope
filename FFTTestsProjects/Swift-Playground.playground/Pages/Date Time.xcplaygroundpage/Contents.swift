//: Playground - noun: a place where people can play


import Foundation

let eightHours:Double = 8*60*60
let eightHoursLater = NSDate().dateByAddingTimeInterval(eightHours)

print(eightHoursLater)

/*
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
[dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];

NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:162000];

NSString *formattedDateString = [dateFormatter stringFromDate:date];
NSLog(@"formattedDateString: %@", formattedDateString);
*/



let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
let timeToWakeUp = dateFormatter.dateFromString("2015-9-16 at 6:40")


let now = NSDate()


timeToWakeUp!.timeIntervalSinceDate(now)/3600.0
