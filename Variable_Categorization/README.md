# Variable Categorization using OpenAI GPT API

**Problem Statement**

The dataset featured a diverse set of variables but did not include a tailored categorization scheme for streamlined filtering or analysis. While a variable dictionary was available, its categories were broad and only covered part of the data. To enable more flexible exploration a custom categorization approach was designed based on each variable’s description.

**Solution Overview**

To create a meaningful structure, variable descriptions were processed using the OpenAI GPT API. This allowed for semantic grouping and consistent categorization, improving the usability and documentation of the dataset. Only variable descriptions (not raw data) were used. 

**Methodology**

1. **Dictionary Cleaning**
   Extracted relevant variable names and descriptions.

2. **Initial Grouping**
   Processed batches of variable descriptions with GPT to propose thematic categories.

3. **Category Consolidation**
   Merged and refined outputs from all batches, resulting in a unified set of 31 categories.

4. **Final Assignment**
   Each variable was assigned to its most relevant category using GPT, producing a fully categorized dictionary.

**Outcome**

The result is a comprehensive, semantically categorized dictionary, mapping each variable to one of 31 coherent groups. This enables:

* Faster variable lookup
* More efficient filtering and feature selection
* Improved dataset documentation and usability
