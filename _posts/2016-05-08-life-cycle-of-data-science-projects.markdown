---
layout: post
title: Life Cycle of Data Science Projects
---
<img src="/images/fulls/10.jpg" class="fit image">
<p>The software development life cycle is well-known by the most IT specialists. In this article I'm going to present you a life cycle customized to data science.</p>

<h3>1. Identify the problem</h3>
<p>First of all, we need to identify the problem that we want to solve (or the question that we want to answer). The type of the problem may be prototyping, proof of concept, root cause analysis, predictive analytics, prescriptive analytics, machine-to-machine implementation and others. After that, we need to identify metrics used to measure success over baseline.
In addition, the following steps might be needed on this phase:</p>
<ul>
<li>Identify key people within your organization and outside</li>
<li>Get specifications, requirements, priorities, budgets</li>
<li>How accurate the solution needs to be?</li>
</ul>

<h3>2. Identify available data sources</h3>
<p>The next phase consist on identifying available data sources. Maybe your company has enough data internally storaged. Otherwise, you need to get the data externally.
Once you have the data, you need to:</p>
<ul>
<li>Extract and check a sample data, using sampling techniques.</li>
<li>Discuss fields to make sure data is understood by you.</li>
<li>Perform EDA (exploratory analysis, data dictionary)</li>
<li>Assess quality of data, and value available in data.</li>
<li>Identify data glitches, find work-around.</li>
<li>Is quality and fields populated consistent over time?</li>
<li>Which tool do I need (R, Excel, Tableau, Python, Perl, Tableau, SAS and so on)</li>
</ul>

<h3>3. Identify if additional data sources are needed</h3>
<p>Sometimes, the data available may be incomplete. In this case, what fields should be captured? How granular should it be? How's the data going to be storaged or accessed?</p>

<h3>4. Statistical Analyses</h3>
<p>Now, we reached out what I consider the most interesting step. Our action depends on which type of data we are handling. The tasks involved on this phase might be:</p>
<ul>
<li>Detect / remove outliers</li>
<li>Selecting variables (variables reduction)</li>
<li>Cross-correlation analysis</li>
<li>Cross-validation, model fitting</li>
<li>Measure accuracy, provide confidence intervals</li>
</ul>


<h3>5. Implementation, development</h3>
<p>A good implementation follow the FSSRR principle: Fast, simple, scalable, robust, re-usable.
To create an API to communicate with other apps might be a good choice.</p>

<h3>6. Communicate results</h3>
<p>A good data scientist is also a good storyteller, to communicate the result is an important task in any kind of projects involving data science. Some questions to be answered on this phase are: Does it need to integrate results in dashboard? Does it need to create an email alert system?</p>
<p> We also have some extra tasks like: Decide on dashboard architecture, discuss potential improvements, provide training, writing a technical report, explaining how your solution should be used, parameters fine-tuned, and results interpreted.</p>

<h3>7. Maintenance</h3>
<p>As in any other project, we have the maintenance phase, that involves testing the model or implementation, stress tests and regular updates.</p>
