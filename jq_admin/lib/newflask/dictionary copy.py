collections_list = [
    "text_collection",
    "author_collection",
    "title_collection",
    "contact_collection",
    "name_collection",
    "position_collection",
    "department_collection",
    "date_collection",
]
fields_list = [
    "text",
    "author",
    "title",
    "contact",
    "name",
    "position",
    "department",
    "date",
]
collections_dict = {
    "text_collection": [
        "uuid",
        "text_id",
        "text",
        "embeds",
        "media",
        "link",
        "partition_name",
    ],
    "author_collection": ["uuid", "author", "embeds", "partition_name"],
    "title_collection": ["uuid", "title", "embeds", "partition_name"],
    "date_collection": ["uuid", "date", "embeds", "partition_name"],
    "contact_collection": ["uuid", "contact", "embeds", "partition_name"],
    "department_collection": ["uuid", "department", "embeds", "partition_name"],
    "name_collection": ["uuid", "name", "embeds", "partition_name"],
    "position_collection": ["uuid", "position", "embeds", "partition_name"],
}

partitions = {
    "documents_partition": [
        "text_collection",
        "author_collection",
        "title_collection",
        "date_collection",
    ],
    "social_posts_partition": ["text_collection", "date_collection"],
    "contacts_partition": [
        "name_collection",
        "text_collection",
        "contact_collection",
        "department_collection",
    ],
    "people_partition": [
        "text_collection",
        "name_collection",
        "position_collection",
        "department_collection",
    ],
    "usjr_documents_partition": ["text_collection", "title_collection"],
    "scs_documents_partition": ["text_collection"],
    "religious_admin_people_partition": [
        "text_collection",
        "name_collection",
        "position_collection",
    ],
}


desired_fields = {
    "text_collection": "text",
    "title_collection": "title",
    "author_collection": "author",
    "contact_collection": "contact",
    "department_collection": "department",
    "name_collection": "name",
    "position_collection": "position",
    "date_collection": "date",
}

table_fields = {
    "documents_partition": [
        "text",
        "author",
        "title",
        "date",
    ],
    "social_posts_partition": ["text", "date"],
    "contacts_partition": [
        "name",
        "text",
        "contact",
        "department",
    ],
    "people_partition": [
        "text",
        "name",
        "position",
        "department",
    ],
}
