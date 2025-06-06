<?php

namespace Leantime\Core;

use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Support\Facades\Log;
use Leantime\Core\Configuration\Environment;
use Leantime\Core\Events\DispatchesEvents;
use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\PHPMailer;

/**
 * Mail class - mails with php mail()
 *
 * @version 1.0
 *
 * @license GNU/AGPL-3.0, see license.txt
 */
class Mailer
{
    use DispatchesEvents;

    public string $cc;

    public string $bcc;

    public string $text = '';

    public string $subject;

    public string $context;

    private PHPMailer $mailAgent;

    /**
     * @var string
     */
    private mixed $emailDomain;

    private Language $language;

    private string $logo;

    private string $companyColor;

    private string $html;

    private bool $hideWrapper = false;

    public bool $nl2br = true;

    /**
     * __construct - get configurations
     *
     * @return void
     */
    public function __construct(Environment $config, Language $language)
    {
        if ($config->email != '') {
            $this->emailDomain = $config->email;
        } else {
            $host = $_SERVER['HTTP_HOST'] ?? 'leantime';
            $this->emailDomain = 'no-reply@'.$host;
        }

        $this->emailDomain = self::dispatch_filter('fromEmail', $this->emailDomain, $this);

        // PHPMailer
        $this->mailAgent = new PHPMailer(false);

        $this->mailAgent->CharSet = 'UTF-8';                    // Ensure UTF-8 is used for emails
        // Use SMTP or php mail().
        if (filter_var($config->useSMTP, FILTER_VALIDATE_BOOLEAN) === true) {
            if ($config->debug) {
                $this->mailAgent->SMTPDebug = 4;                // ensure all aspects (connection, TLS, SMTP, etc) are covered
                $this->mailAgent->Debugoutput = function ($str, $level) {

                    Log::debug($level.' '.$str);
                };
            } else {
                $this->mailAgent->SMTPDebug = 0;
            }

            $this->mailAgent->Timeout = 20;

            $this->mailAgent->isSMTP();                                      // Set mailer to use SMTP
            $this->mailAgent->Host = $config->smtpHosts;          // Specify main and backup SMTP servers

            if (isset($config->smtpAuth)) {
                $this->mailAgent->SMTPAuth = filter_var($config->smtpAuth, FILTER_VALIDATE_BOOLEAN);             // Enable SMTP user/password authentication
            } else {
                $this->mailAgent->SMTPAuth = true;
            }

            $this->mailAgent->Username = $config->smtpUsername;                 // SMTP username
            $this->mailAgent->Password = $config->smtpPassword;                           // SMTP password
            $this->mailAgent->SMTPAutoTLS = $config->smtpAutoTLS ?? true;                 // Enable TLS encryption automatically if a server supports it
            $this->mailAgent->SMTPSecure = $config->smtpSecure;                            // Enable TLS encryption, `ssl` also accepted
            $this->mailAgent->Port = (int) $config->smtpPort;                                    // TCP port to connect to
            if (isset($config->smtpSSLNoverify) && filter_var($config->smtpSSLNoverify, FILTER_VALIDATE_BOOLEAN) === true) {     // If enabled, don't verify certifcates: accept self-signed or expired certs.
                $this->mailAgent->SMTPOptions = [
                    'ssl' => [
                        'verify_peer' => false,
                        'verify_peer_name' => false,
                        'allow_self_signed' => true,
                    ],
                ];
            }
        } else {
            $this->mailAgent->isMail();
        }

        $this->logo = ! session()->has('companysettings.logoPath') ? '/dist/images/logo_blue.png' : session('companysettings.logoPath');
        $this->companyColor = ! session()->has('companysettings.primarycolor') ? '#006c9e' : session('companysettings.primarycolor');

        $this->language = $language;
    }

    /**
     * setContext - sets the context for the mailing
     * (used for filters & events)
     */
    public function setContext($context): void
    {
        $this->context = $context;
    }

    /**
     * setText - sets the mailtext
     */
    public function setText($text): void
    {
        $this->text = $text;
    }

    /**
     * setHTML - set Mail html (no function yet)
     *
     * @param  false  $hideWrapper
     */
    public function setHtml($html, bool $hideWrapper = false): void
    {
        $this->hideWrapper = $hideWrapper;
        $this->html = $html;
    }

    /**
     * setSubject - set mail subject
     */
    public function setSubject($subject): void
    {
        $this->subject = $subject;
    }

    /**
     * dispatchMailerEvent - dispatches a mailer event
     */
    private function dispatchMailerEvent($hookname, $payload, array $additional_params = []): void
    {
        $this->dispatchMailerHook('event', $hookname, $payload, $additional_params);
    }

    /**
     * dispatchMailerFilter - dispatches a mailer filter
     */
    private function dispatchMailerFilter($hookname, $payload, array $additional_params = []): mixed
    {
        return $this->dispatchMailerHook('filter', $hookname, $payload, $additional_params);
    }

    /**
     * dispatchMailerHook - dispatches a mailer hook
     *
     * @throws BindingResolutionException
     */
    private function dispatchMailerHook($type, $hookname, $payload, array $additional_params = []): mixed
    {
        if ($type !== 'filter' && $type !== 'event') {
            return false;
        }

        $hooks = [$hookname];

        if (! empty($this->context)) {
            $hooks[] = "$hookname.{$this->context}";
        }

        $filteredValue = null;
        foreach ($hooks as $hook) {
            if ($type == 'filter') {
                $filteredValue = self::dispatch_filter($hook, $payload, $additional_params);
            } elseif ($type == 'event') {
                self::dispatch_event($hook, $payload);
            }
        }

        if ($type == 'filter') {
            return $filteredValue;
        }

        return null;
    }

    /**
     * sendMail - send the mail with mail()
     *
     * @throws Exception
     */
    public function sendMail(array $to, $from): void
    {
        $this->dispatchMailerEvent('beforeSendMail', []);

        $to = $this->dispatchMailerFilter('sendMailTo', $to, []);
        $from = $this->dispatchMailerFilter('sendMailFrom', $from, []);

        $this->mailAgent->isHTML(true); // Set email format to HTML

        $this->mailAgent->setFrom($this->emailDomain, $from.' (Leantime)');

        $this->mailAgent->Subject = $this->subject;

        if (str_contains($this->logo, 'images/logo.svg')) {
            $this->logo = '/dist/images/logo_blue.png';
        }

        $logoParts = parse_url($this->logo);

        if (isset($logoParts['scheme'])) {
            // Logo is URL
            $inlineLogoContent = $this->logo;
        } else {
            if (file_exists(ROOT.''.$this->logo) && $this->logo != '' && is_file(ROOT.''.$this->logo)) {
                // Logo comes from local file system
                $this->mailAgent->addEmbeddedImage(ROOT.''.$this->logo, 'companylogo');
            } else {
                $this->mailAgent->addEmbeddedImage(ROOT.'/dist/images/logo_blue.png', 'companylogo');
            }

            $inlineLogoContent = 'cid:companylogo';
        }

        $mailBody = $this->hideWrapper ? $this->html : app('blade.compiler')::render(
            $this->dispatchMailerFilter('bodyTemplate', '<table width="100%" style="background:#fefefe; padding:15px; ">
                <tr>
                    <td align="center" valign="top">
                        <table width="600"  style="width:600px; background-color:#ffffff; border:1px solid #ccc; border-radius:5px;">
                            <tr>
                                <td style="padding:20px 10px; text-align:center;">
                                   <img alt="Logo" src="{!! $inlineLogoContent !!}" width="150" style="width:150px;">
                                </td>
                            </tr>
                            <tr>
                                <td style=\'padding:10px; font-family:"Lato","Helvetica Neue",helvetica,sans-serif; color:#666; font-size:16px; line-height:1.7;\'>
                                    {!! $headline !!}
                                    <br/>
                                    {!! $content !!}
                                    <br/><br/>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align="center" style=\'padding:10px; font-family:"Lato","Helvetica Neue",helvetica,sans-serif; color:#666; font-size:14px; line-height:1.7;\'>
                        {!! $unsub_link !!}
                    </td>
                </tr>
            </table>'),
            $this->dispatchMailerFilter(
                'mailBodyParams',
                [
                    'inlineLogoContent' => $inlineLogoContent,
                    'headline' => $this->language->__('email_notifications.hi'),
                    'content' => $this->nl2br ? nl2br($this->html) : $this->html,
                    'unsub_link' => sprintf($this->language->__('email_notifications.unsubscribe'), BASE_URL.'/users/editOwn/'),
                ]
            )
        );

        $mailBody = $this->dispatchMailerFilter(
            'bodyContent',
            $mailBody,
            [
                [
                    'companyColor' => $this->companyColor,
                    'logoUrl' => $inlineLogoContent,
                    'languageHiText' => $this->language->__('email_notifications.hi'),
                    'emailContentsHtml' => nl2br($this->html),
                    'unsubLink' => sprintf($this->language->__('email_notifications.unsubscribe'), BASE_URL.'/users/editOwn/'),
                ],
            ]
        );

        $this->mailAgent->Body = $mailBody;

        $altBody = $this->dispatchMailerFilter(
            'altBody',
            $this->text,
            []
        );

        $this->mailAgent->AltBody = $altBody;

        if (is_array($to)) {
            $to = array_unique($to);

            foreach ($to as $recip) {
                try {
                    $this->mailAgent->addAddress($recip);
                    $this->mailAgent->send();
                } catch (Exception $e) {
                    Log::error($this->mailAgent->ErrorInfo);
                    Log::error($e);
                }

                $this->mailAgent->clearAllRecipients();
            }
        }

        $this->dispatchMailerEvent('afterSendMail', $to);
    }
}
