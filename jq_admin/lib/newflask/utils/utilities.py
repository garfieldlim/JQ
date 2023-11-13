import datetime


def refactor_date(input_date):
    # Parse the input date using datetime.datetime.strptime
    parsed_date = datetime.strptime(input_date, "%a, %d %b %Y %H:%M:%S %Z")

    # Format the date in the desired format
    formatted_date = parsed_date.strftime("%Y-%m-%d %B %d %Y")
    return formatted_date
