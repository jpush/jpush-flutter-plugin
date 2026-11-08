def positive_total(values):
    if any(value < 0 for value in values):
        raise ValueError("negative value")
    return sum(values)
