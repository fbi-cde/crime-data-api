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
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
  from asr_data_group_male_view a
  join agency_data agy on agy.agency_id=a.agency_id
  group by a.data_year, a.agency_id, ori, age_group
  order by a.data_year, ori, age_group

  CREATE MATERIALIZED VIEW public.asr_age_male_count_state AS
    select a.data_year, agy.state_abbr as state_abbr, age_group,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
    from asr_data_group_male_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, state_abbr, age_group
    order by a.data_year, state_abbr, age_group

  CREATE MATERIALIZED VIEW public.asr_age_male_count_region AS
    select a.data_year, agy.region_name as region_name, age_group,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
    (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
    from asr_data_group_male_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, region_name, age_group
    order by a.data_year, region_name, age_group

CREATE MATERIALIZED VIEW public.asr_age_male_count_national AS
  select data_year, age_group,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
  (select sum(cnt) from asr_data_group_male_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
  from asr_data_group_male_view a
  group by data_year, age_group
  order by data_year, age_group

CREATE MATERIALIZED VIEW public.asr_age_male_count_agency AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  asr.AGENCY_ID as agency_id,
  agy.ori as ori,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,asr.agency_id,ori
order by asr.data_year,ori,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_state AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.STATE_ABBR as state_abbr,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,state_abbr
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_region AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.region_name as region_name,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,region_name
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_male_count_national AS
SELECT asr.DATA_YEAR as DATA_YEAR,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(M_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_10_TO_12_ARR_CNT)+sum(M_AGE_13_TO_14_ARR_CNT)+sum(M_AGE_15_ARR_CNT)+sum(M_AGE_16_ARR_CNT)+sum(M_AGE_17_ARR_CNT)+sum(M_AGE_18_ARR_CNT)+sum(M_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(M_AGE_20_ARR_CNT)+sum(M_AGE_21_ARR_CNT)+sum(M_AGE_22_ARR_CNT)+sum(M_AGE_23_ARR_CNT)+sum(M_AGE_24_ARR_CNT)+sum(M_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(M_AGE_30_TO_34_ARR_CNT)+sum(M_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(M_AGE_40_TO_44_ARR_CNT)+sum(M_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(M_AGE_50_TO_54_ARR_CNT)+sum(M_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(M_AGE_60_TO_64_ARR_CNT)+sum(M_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID;

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
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
  from asr_data_group_female_view a
  join agency_data agy on agy.agency_id=a.agency_id
  group by a.data_year, a.agency_id, ori, age_group
  order by a.data_year, ori, age_group

  -- CREATE MATERIALIZED VIEW public.asr_age_female_count_state ran in 1 hour 53min 52sec
  CREATE MATERIALIZED VIEW public.asr_age_female_count_state AS
    select a.data_year, agy.state_abbr as state_abbr, age_group,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
    from asr_data_group_female_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, state_abbr, age_group
    order by a.data_year, state_abbr, age_group

  -- CREATE MATERIALIZED VIEW public.asr_age_female_count_region ran in 11min 29sec
  CREATE MATERIALIZED VIEW public.asr_age_female_count_region AS
    select a.data_year, agy.region_name as region_name, age_group,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
    (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
    from asr_data_group_female_view a
    join agency_data agy on agy.agency_id=a.agency_id
    group by a.data_year, region_name, age_group
    order by a.data_year, region_name, age_group

-- CREATE MATERIALIZED VIEW public.asr_age_female_count_national ran in 2min 15sec
CREATE MATERIALIZED VIEW public.asr_age_female_count_national AS
  select data_year, age_group,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Aggravated Assault') as Aggravated_Assault,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='All Other Offenses (Except Traffic)') as All_Other_Offenses_Except_Traffic,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Arson') as Arson,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Burglary - Breaking or Entering') as Burglary_Breaking_or_Entering,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Curfew and Loitering Law Violations') as Curfew_and_Loitering_Law_Violations,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Disorderly Conduct') as Disorderly_Conduct,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Driving Under the Influence') as Driving_Under_the_Influence,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Abuse Violations - Grand Total') as Drug_Abuse_Violations_Grand_Total,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Marijuana') as Drug_Possession_Marijuana,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Opium or Cocaine or Their Derivatives') as Drug_Possession_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Other - Dangerous Nonnarcotic Drugs') as Drug_Possession_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Subtotal') as Drug_Possession_Subtotal,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Possession - Synthetic Narcotics') as Drug_Possession_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Marijuana') as Drug_Sale_Manufacturing_Marijuana,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives') as Drug_Sale_Manufacturing_Opium_or_Cocaine_or_Their_Derivatives,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs') as Drug_Sale_Manufacturing_Other_Dangerous_Nonnarcotic_Drugs,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Subtotal') as Drug_Sale_Manufacturing_Subtotal,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drug Sale/Manufacturing - Synthetic Narcotics') as Drug_Sale_Manufacturing_Synthetic_Narcotics,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Drunkenness') as Drunkenness,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Embezzlement') as Embezzlement,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Forgery and Counterfeiting') as Forgery_and_Counterfeiting,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Fraud') as Fraud,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - All Other Gambling') as Gambling_All_Other_Gambling,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Bookmaking (Horse and Sport Book)') as Gambling_Bookmaking_Horse_and_Sport_Book,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Numbers and Lottery') as Gambling_Numbers_and_Lottery,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Gambling - Total') as Gambling_Total,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Commercial Sex Acts') as Human_Trafficking_Commercial_Sex_Acts,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Human Trafficking - Involuntary Servitude') as Human_Trafficking_Involuntary_Servitude,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Juvenile Disposition') as Juvenile_Disposition,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Larceny - Theft') as Larceny_Theft,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Liquor Laws') as Liquor_Laws,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Manslaughter by Negligence') as Manslaughter_by_Negligence,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Motor Vehicle Theft') as Motor_Vehicle_Theft,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Murder and Nonnegligent Manslaughter') as Murder_and_Nonnegligent_Manslaughter,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Offenses Against the Family and Children') as Offenses_Against_the_Family_and_Children,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice') as Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Assisting or Promoting Prostitution') as Prostitution_and_Commercialized_Vice_Assisting_or_Promoting_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Prostitution') as Prostitution_and_Commercialized_Vice_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Prostitution and Commercialized Vice - Purchasing Prostitution') as Prostitution_and_Commercialized_Vice_Purchasing_Prostitution,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Rape') as Rape,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Robbery') as Robbery,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Runaway') as Runaway,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)') as Sex_Offenses_Except_Rape_and_Prostitution_and_Commercialized_Vice,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Simple Assault') as Simple_Assault,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Stolen Property: Buying, Receiving, Possessing') as Stolen_Property_Buying_Receiving_Possessing,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Suspicion') as Suspicion,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vagrancy') as Vagrancy,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Vandalism') as Vandalism,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Weapons: Carrying, Possessing, Etc.') as Weapons_Carrying_Possessing_Etc,
  (select sum(cnt) from asr_data_group_female_view b where a.data_year=b.data_year and a.age_group=b.age_group and offense_name='Zero Report') as Zero_Report
  from asr_data_group_female_view a
  group by data_year, age_group
  order by data_year, age_group

CREATE MATERIALIZED VIEW public.asr_age_female_count_agency AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  asr.AGENCY_ID as agency_id,
  agy.ori as ori,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,asr.agency_id,ori
order by asr.data_year,ori,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_state AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.STATE_ABBR as state_abbr,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,state_abbr
order by asr.data_year,state_abbr,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_region AS
  SELECT asr.DATA_YEAR as DATA_YEAR,
  agy.region_name as region_name,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
join agency_data agy on agy.agency_id=asr.agency_id
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME,region_name
order by asr.data_year,region_name,OFFENSE_SUBCAT_ID;

CREATE MATERIALIZED VIEW public.asr_age_female_count_national AS
SELECT asr.DATA_YEAR as DATA_YEAR,
  OFFENSE_SUBCAT_ID as offense_id,
  OFFENSE_SUBCAT_NAME as offense_name,
  coalesce(sum(F_AGE_UNDER_10_ARR_CNT),0) as AGE_0_TO_9,
  coalesce(sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_10_TO_12_ARR_CNT)+sum(F_AGE_13_TO_14_ARR_CNT)+sum(F_AGE_15_ARR_CNT)+sum(F_AGE_16_ARR_CNT)+sum(F_AGE_17_ARR_CNT)+sum(F_AGE_18_ARR_CNT)+sum(F_AGE_19_ARR_CNT),0) as AGE_10_TO_19,
  coalesce(sum(F_AGE_20_ARR_CNT)+sum(F_AGE_21_ARR_CNT)+sum(F_AGE_22_ARR_CNT)+sum(F_AGE_23_ARR_CNT)+sum(F_AGE_24_ARR_CNT)+sum(F_AGE_25_TO_29_ARR_CNT),0) as AGE_20_TO_29,
  coalesce(sum(F_AGE_30_TO_34_ARR_CNT)+sum(F_AGE_35_TO_39_ARR_CNT),0) as AGE_30_TO_39,
  coalesce(sum(F_AGE_40_TO_44_ARR_CNT)+sum(F_AGE_45_TO_49_ARR_CNT),0) as AGE_40_TO_49,
  coalesce(sum(F_AGE_50_TO_54_ARR_CNT)+sum(F_AGE_55_TO_59_ARR_CNT),0) as AGE_50_TO_59,
  coalesce(sum(F_AGE_60_TO_64_ARR_CNT)+sum(F_AGE_OVER_64_ARR_CNT),0) as AGE_OVER_60
from public.asr_data asr
group by asr.data_year,OFFENSE_SUBCAT_ID, OFFENSE_SUBCAT_NAME
order by asr.data_year,OFFENSE_SUBCAT_ID;

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
