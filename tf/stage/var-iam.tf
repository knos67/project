variable "iam_role" {
    type = map(object({
        name = string
        fname = string
        tags = object({
            Name = string
        })
    }))
}

variable "iam_policy" {
    type = map(object({
        name = string
        description = string
        fname = string
        tags = object({
            Name = string
        })
    }))
}