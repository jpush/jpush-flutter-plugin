def total(values):
    result = 0
    for value in values:
        if value < 0:
            raise ValueError("negative value")
        result += value
    return result
