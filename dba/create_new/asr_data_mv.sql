CREATE MATERIALIZED VIEW public.asr_data_group_male_view AS
    select data_year, agency_id, '0-9' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_UNDER_10_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '10-19' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_10_TO_12_ARR_CNT+M_AGE_13_TO_14_ARR_CNT+M_AGE_15_ARR_CNT+M_AGE_16_ARR_CNT+M_AGE_17_ARR_CNT+M_AGE_18_ARR_CNT+M_AGE_19_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '20-29' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_20_ARR_CNT+M_AGE_21_ARR_CNT+M_AGE_22_ARR_CNT+M_AGE_23_ARR_CNT+M_AGE_24_ARR_CNT+M_AGE_25_TO_29_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '30-39' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_30_TO_34_ARR_CNT+M_AGE_35_TO_39_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '40-49' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_40_TO_44_ARR_CNT+M_AGE_45_TO_49_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '50-59' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_50_TO_54_ARR_CNT+M_AGE_55_TO_59_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, 'Over 60' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(M_AGE_60_TO_64_ARR_CNT+M_AGE_OVER_64_ARR_CNT) as cn
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  order by age_group, agency_id, offense_name

  CREATE MATERIALIZED VIEW public.asr_age_male_count_agency AS
    select a.data_year, a.agency_id, agy.ori as ori, age_group,
    sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
    sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
    sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
    sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
    sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
    sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
    sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
    sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
    sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
    sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
    sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
    sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
    sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
    sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
    sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
    sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
    sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
    sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
    sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
    sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
    sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
    sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
    sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
    sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
    sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
    sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
    sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
    sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
    sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
    sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
    sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
    sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
    sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
    sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
    sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
    sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
    from asr_data_group_male_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, a.agency_id, ori, age_group
    order by a.data_year, ori, age_group

  CREATE MATERIALIZED VIEW public.asr_age_male_count_state AS
    select a.data_year, agy.state_abbr as state_abbr, age_group,
    sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
    sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
    sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
    sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
    sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
    sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
    sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
    sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
    sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
    sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
    sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
    sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
    sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
    sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
    sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
    sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
    sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
    sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
    sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
    sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
    sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
    sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
    sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
    sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
    sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
    sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
    sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
    sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
    sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
    sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
    sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
    sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
    sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
    sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
    sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
    sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
    from asr_data_group_male_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, state_abbr, age_group
    order by a.data_year, state_abbr, age_group

  CREATE MATERIALIZED VIEW public.asr_age_male_count_region AS
    select a.data_year, agy.region_name as region_name, age_group,
    sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
    sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
    sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
    sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
    sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
    sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
    sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
    sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
    sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
    sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
    sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
    sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
    sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
    sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
    sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
    sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
    sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
    sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
    sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
    sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
    sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
    sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
    sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
    sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
    sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
    sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
    sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
    sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
    sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
    sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
    sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
    sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
    sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
    sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
    sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
    sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
    from asr_data_group_male_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, region_name, age_group
    order by a.data_year, region_name, age_group

CREATE MATERIALIZED VIEW public.asr_age_male_count_national AS
  select data_year, age_group,
  sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
  sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
  sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
  sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
  sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
  sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
  sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
  sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
  sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
  sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
  sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
  sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
  sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
  sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
  sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
  sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
  sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
  sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
  sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
  sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
  sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
  sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
  sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
  sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
  sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
  sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
  sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
  sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
  sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
  sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
  sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
  sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
  sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
  sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
  sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
  sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
  from asr_data_group_male_view
  group by data_year, age_group
  order by data_year, age_group

CREATE MATERIALIZED VIEW public.asr_data_group_female_view AS
    select data_year, agency_id, '0-9' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_UNDER_10_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '10-19' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_10_TO_12_ARR_CNT+F_AGE_13_TO_14_ARR_CNT+F_AGE_15_ARR_CNT+F_AGE_16_ARR_CNT+F_AGE_17_ARR_CNT+F_AGE_18_ARR_CNT+F_AGE_19_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '20-29' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_20_ARR_CNT+F_AGE_21_ARR_CNT+F_AGE_22_ARR_CNT+F_AGE_23_ARR_CNT+F_AGE_24_ARR_CNT+F_AGE_25_TO_29_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '30-39' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_30_TO_34_ARR_CNT+F_AGE_35_TO_39_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '40-49' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_40_TO_44_ARR_CNT+F_AGE_45_TO_49_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, '50-59' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_50_TO_54_ARR_CNT+F_AGE_55_TO_59_ARR_CNT) as cnt
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  union all
    select data_year, agency_id, 'Over 60' as age_group, OFFENSE_SUBCAT_NAME as offense_name,
    sum(F_AGE_60_TO_64_ARR_CNT+F_AGE_OVER_64_ARR_CNT) as cn
    from asr_data
    group by data_year, agency_id, OFFENSE_SUBCAT_NAME
  order by age_group, agency_id, offense_name

  CREATE MATERIALIZED VIEW public.asr_age_female_count_agency AS
  select a.data_year, a.agency_id, agy.ori as ori, age_group,
  sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
  sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
  sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
  sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
  sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
  sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
  sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
  sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
  sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
  sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
  sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
  sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
  sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
  sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
  sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
  sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
  sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
  sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
  sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
  sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
  sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
  sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
  sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
  sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
  sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
  sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
  sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
  sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
  sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
  sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
  sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
  sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
  sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
  sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
  sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
  sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
  from asr_data_group_female_view a
  join agency_data agy on agy.agency_id=a.agency_id
  group by a.data_year, a.agency_id, ori, age_group
  order by a.data_year, ori, age_group

  CREATE MATERIALIZED VIEW public.asr_age_female_count_state AS
    select a.data_year, agy.state_abbr as state_abbr, age_group,
    sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
    sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
    sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
    sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
    sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
    sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
    sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
    sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
    sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
    sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
    sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
    sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
    sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
    sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
    sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
    sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
    sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
    sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
    sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
    sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
    sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
    sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
    sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
    sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
    sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
    sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
    sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
    sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
    sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
    sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
    sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
    sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
    sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
    sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
    sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
    sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
    from asr_data_group_female_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, state_abbr, age_group
    order by a.data_year, state_abbr, age_group

  CREATE MATERIALIZED VIEW public.asr_age_female_count_region AS
    select a.data_year, agy.region_name as region_name, age_group,
    sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
    sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
    sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
    sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
    sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
    sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
    sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
    sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
    sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
    sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
    sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
    sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
    sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
    sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
    sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
    sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
    sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
    sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
    sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
    sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
    sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
    sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
    sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
    sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
    sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
    sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
    sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
    sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
    sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
    sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
    sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
    sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
    sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
    sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
    sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
    sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
    sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
    sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
    from asr_data_group_female_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, region_name, age_group
    order by a.data_year, region_name, age_group

CREATE MATERIALIZED VIEW public.asr_age_female_count_national AS
  select data_year, age_group,
  sum(CASE WHEN offense_name='Aggravated Assault' then cnt else 0 end) as Aggravated_Assault,
  sum(CASE WHEN offense_name='All Other Offenses (Except Traffic)' then cnt else 0 end) as All_Other_Offenses_Except_Traffic,
  sum(CASE WHEN offense_name='Arson' then cnt else 0 end) as Arson,
  sum(CASE WHEN offense_name='Burglary - Breaking or Entering' then cnt else 0 end) as Burglary_Breaking_or_Entering,
  sum(CASE WHEN offense_name='Curfew and Loitering Law Violations' then cnt else 0 end) as Curfew_and_Loitering_Law_Violations,
  sum(CASE WHEN offense_name='Disorderly Conduct' then cnt else 0 end) as Disorderly_Conduct,
  sum(CASE WHEN offense_name='Driving Under the Influence' then cnt else 0 end) as Driving_Under_the_Influence,
  sum(CASE WHEN offense_name='Drug Abuse Violations - Grand Total' then cnt else 0 end) as Drug_Abuse_Violations_Grand_Total,
  sum(CASE WHEN offense_name='Drug Possession - Marijuana' then cnt else 0 end) as Drug_Possession_Marijuana,
  sum(CASE WHEN offense_name='Drug Possession - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Possession - Subtotal' then cnt else 0 end) as Drug_Possession_Subtotal,
  sum(CASE WHEN offense_name='Drug Possession - Synthetic Narcotics' then cnt else 0 end) as Drug_Possession_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Marijuana' then cnt else 0 end) as Drug_Sale_Manufacturing_Marijuana,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives' then cnt else 0 end) as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs' then cnt else 0 end) as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Subtotal' then cnt else 0 end) as Drug_Sale_Manufacturing_Subtotal,
  sum(CASE WHEN offense_name='Drug Sale/Manufacturing - Synthetic Narcotics' then cnt else 0 end) as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  sum(CASE WHEN offense_name='Drunkenness' then cnt else 0 end) as Drunkenness,
  sum(CASE WHEN offense_name='Embezzlement' then cnt else 0 end) as Embezzlement,
  sum(CASE WHEN offense_name='Forgery and Counterfeiting' then cnt else 0 end) as Forgery_and_Counterfeiting,
  sum(CASE WHEN offense_name='Fraud' then cnt else 0 end) as Fraud,
  sum(CASE WHEN offense_name='Gambling - All Other Gambling' then cnt else 0 end) as Gambling_All_Other_Gambling,
  sum(CASE WHEN offense_name='Gambling - Bookmaking (Horse and Sport Book)' then cnt else 0 end) as Gambling_Bookmaking_Horse_and_Sport_Book,
  sum(CASE WHEN offense_name='Gambling - Numbers and Lottery' then cnt else 0 end) as Gambling_Numbers_and_Lottery,
  sum(CASE WHEN offense_name='Gambling - Total' then cnt else 0 end) as Gambling_Total,
  sum(CASE WHEN offense_name='Human Trafficking - Commercial Sex Acts' then cnt else 0 end) as Human_Trafficking_Commercial_Sex_Acts,
  sum(CASE WHEN offense_name='Human Trafficking - Involuntary Servitude' then cnt else 0 end) as Human_Trafficking_Involuntary_Servitude,
  sum(CASE WHEN offense_name='Juvenile Disposition' then cnt else 0 end) as Juvenile_Disposition,
  sum(CASE WHEN offense_name='Larceny - Theft' then cnt else 0 end) as Larceny_Theft,
  sum(CASE WHEN offense_name='Liquor Laws' then cnt else 0 end) as Liquor_Laws,
  sum(CASE WHEN offense_name='Manslaughter by Negligence' then cnt else 0 end) as Manslaughter_by_Negligence,
  sum(CASE WHEN offense_name='Motor Vehicle Theft' then cnt else 0 end) as Motor_Vehicle_Theft,
  sum(CASE WHEN offense_name='Murder and Nonnegligent Manslaughter' then cnt else 0 end) as Murder_and_Nonnegligent_Manslaughter,
  sum(CASE WHEN offense_name='Offenses Against the Family and Children' then cnt else 0 end) as Offenses_Against_the_Family_and_Children,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice' then cnt else 0 end) as Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Prostitution,
  sum(CASE WHEN offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution' then cnt else 0 end) as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  sum(CASE WHEN offense_name='Rape' then cnt else 0 end) as Rape,
  sum(CASE WHEN offense_name='Robbery' then cnt else 0 end) as Robbery,
  sum(CASE WHEN offense_name='Runaway' then cnt else 0 end) as Runaway,
  sum(CASE WHEN offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)' then cnt else 0 end) as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  sum(CASE WHEN offense_name='Simple Assault' then cnt else 0 end) as Simple_Assault,
  sum(CASE WHEN offense_name='Stolen Property: Buying, Receiving, Possessing' then cnt else 0 end) as Stolen_Property_Buying_Receiving_Possessing,
  sum(CASE WHEN offense_name='Suspicion' then cnt else 0 end) as Suspicion,
  sum(CASE WHEN offense_name='Vagrancy' then cnt else 0 end) as Vagrancy,
  sum(CASE WHEN offense_name='Vandalism' then cnt else 0 end) as Vandalism,
  sum(CASE WHEN offense_name='Weapons: Carrying, Possessing, Etc.' then cnt else 0 end) as Weapons_Carrying_Possessing_Etc,
  sum(CASE WHEN offense_name='Zero Report' then cnt else 0 end) as Zero_Report
  from asr_data_group_female_view a
  group by data_year, age_group
  order by data_year, age_group

CREATE MATERIALIZED VIEW public.asr_race_count_agency AS
                SELECT DATA_YEAR as DATA_YEAR,
                AGENCY_ID as agency_id,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data group by data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,agency_id;

CREATE MATERIALIZED VIEW public.asr_race_count_state AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.state_abbr as state_abbr,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,state_abbr,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_count_region AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.region_name as region_name,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,region_name,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_count_national AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,offense_subcat_id;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_agency AS
                SELECT DATA_YEAR as DATA_YEAR,
                AGENCY_ID as agency_id,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data group by data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,agency_id;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_state AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.state_abbr as state_abbr,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_region AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                agy.region_name as region_name,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;

CREATE MATERIALIZED VIEW public.asr_race_yth_count_national AS
                SELECT asr.DATA_YEAR as DATA_YEAR,
                OFFENSE_SUBCAT_ID as offense_id,
                OFFENSE_SUBCAT_NAME as offense_name,
                coalesce(sum( RACE_UNKNOWN_YTH_ARR_CNT)) as UNKNOWN,
                coalesce(sum( RACE_WHITE_YTH_ARR_CNT)) as WHITE,
                coalesce(sum( RACE_BLACK_YTH_ARR_CNT)) as BLACK,
                coalesce(sum( RACE_AMIAN_YTH_ARR_CNT)) as AMIAN,
                coalesce(sum( RACE_ASIAN_YTH_ARR_CNT)) as ASIAN,
                coalesce(sum( RACE_ANHOPI_YTH_ARR_CNT)) as ANHOPI,
                coalesce(sum( RACE_CHINESE_YTH_ARR_CNT)) as CHINESE,
                coalesce(sum( RACE_JAPANESE_YTH_ARR_CNT)) as JAPANESE,
                coalesce(sum( RACE_NHOPI_YTH_ARR_CNT)) as NHOPI,
                coalesce(sum( RACE_OTHER_YTH_ARR_CNT)) as OTHER,
                coalesce(sum( RACE_MULTIPLE_YTH_ARR_CNT)) as MULTIPLE,
                coalesce(sum( RACE_NOT_SPECIFIED_YTH_ARR_CNT)) as NOT_SPECIFIED
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME;
